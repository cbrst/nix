# nixie: day-to-day management of this NixOS / Home Manager flake.
#
# Run without arguments for the interactive menu, or use a subcommand (see
# `nixie help`). writeShellApplication provides errexit, nounset and pipefail.

nixie_version=0.1.0

# --- Environment -------------------------------------------------------------

user=${USER:-$(id -un)}
host=${NIXIE_HOST:-$(uname -n)}
host=${host%%.*}
host=$(printf '%s' "$host" | tr '[:upper:]' '[:lower:]')

# The checkout comes from NIXIE_FLAKE, else from the config file, which Home
# Manager writes from programs.nixie.flake. The file holds "key = value" lines
# and "#" comments; it is parsed, never sourced.
config_file=${XDG_CONFIG_HOME:-$HOME/.config}/nixie/config

config_get() {
  [[ -r $config_file ]] || return 0
  awk -v key="$1" '
    { sub(/^[ \t]+/, ""); sub(/[ \t]+$/, "") }
    /^#/ || !/=/ { next }
    {
      k = $0; sub(/[ \t]*=.*/, "", k)
      if (k != key) next
      v = $0; sub(/^[^=]*=[ \t]*/, "", v)
      value = v
    }
    END { if (value != "") print value }
  ' "$config_file"
}

if [[ -n ${NIXIE_FLAKE:-} ]]; then
  flake=$NIXIE_FLAKE
  flake_source="NIXIE_FLAKE"
else
  flake=$(config_get flake)
  flake_source=${flake:+$config_file}
fi
flake=${flake/#\~/$HOME}
flake=${flake%/}

# "nixos": NixOS with Home Manager embedded in the system configuration.
# "home": standalone Home Manager (macOS or another Linux).
if [[ -e /etc/NIXOS ]]; then
  mode=nixos
  system_attr="nixosConfigurations.$host.config.system.build.toplevel"
  home_attr="nixosConfigurations.$host.config.home-manager.users.$user.home.activationPackage"
  current_home="${XDG_STATE_HOME:-$HOME/.local/state}/home-manager/gcroots/current-home"
else
  mode=home
  system_attr=""
  home_attr="homeConfigurations.\"$user@$host\".activationPackage"
  current_home="${XDG_STATE_HOME:-$HOME/.local/state}/nix/profiles/home-manager"
fi

system_profile=/nix/var/nix/profiles/system
user_profiles=(
  "${XDG_STATE_HOME:-$HOME/.local/state}/nix/profiles/profile"
  "${XDG_STATE_HOME:-$HOME/.local/state}/nix/profiles/home-manager"
)

assume_yes=0
dry_run=0

tmpdir=$(mktemp -d "${TMPDIR:-/tmp}/nixie.XXXXXX")
trap 'rm -rf "$tmpdir"; [[ -t 2 ]] && printf "\e[?25h" >&2' EXIT

# --- Presentation ------------------------------------------------------------

# ANSI colour numbers, so gum follows the terminal palette (which this flake
# renders from lib/themes.nix) in both light and dark variants.
c_accent=4
c_alt=5
c_ok=2
c_warn=3
c_err=1
c_dim=8

export GUM_CHOOSE_CURSOR_FOREGROUND=$c_accent
export GUM_CHOOSE_HEADER_FOREGROUND=$c_alt
export GUM_CHOOSE_SELECTED_FOREGROUND=$c_accent
export GUM_CHOOSE_CURSOR="› "
export GUM_CONFIRM_PROMPT_FOREGROUND=$c_alt
export GUM_CONFIRM_SELECTED_BACKGROUND=$c_accent
export GUM_SPIN_SPINNER=${GUM_SPIN_SPINNER:-dot}
export GUM_SPIN_SPINNER_FOREGROUND=$c_accent
export GUM_TABLE_BORDER_FOREGROUND=$c_dim
export GUM_TABLE_HEADER_FOREGROUND=$c_alt

is_interactive() { [[ -t 0 && -t 1 ]]; }
is_tty_out() { [[ -t 2 && -z ${NO_COLOR:-} ]]; }

# Every human-facing message goes to stderr; stdout stays for data.
style() { gum style "$@" >&2; }

banner() {
  if is_tty_out; then
    local title sub
    title=$(CLICOLOR_FORCE=1 gum style --bold --foreground "$c_accent" "nixie")
    sub=$(CLICOLOR_FORCE=1 gum style --foreground "$c_dim" "$host · $mode · ${flake:+${flake/#"$HOME"/\~}}${flake:-no flake}")
    gum style --border rounded --border-foreground "$c_dim" --padding "0 2" --margin "0 1" \
      "$(CLICOLOR_FORCE=1 gum join --horizontal "$title" "  " "$sub")" >&2
  else
    echo "nixie $nixie_version · $host · $mode · ${flake:-no flake}" >&2
  fi
}

section() {
  if is_tty_out; then
    style --bold --foreground "$c_alt" --margin "1 0 1 1" "▸ $*"
  else
    echo "== $*" >&2
  fi
}

note() {
  if is_tty_out; then
    style --margin "0 0 0 1" --foreground "$c_dim" "  $*"
  else
    echo "  $*" >&2
  fi
}
ok() {
  if is_tty_out; then
    style --margin "0 0 0 1" --foreground "$c_ok" "✓ $*"
  else
    echo "OK $*" >&2
  fi
}
warn() {
  if is_tty_out; then
    style --margin "0 0 0 1" --foreground "$c_warn" "! $*"
  else
    echo "WARN $*" >&2
  fi
}
fail() {
  if is_tty_out; then
    style --margin "0 0 0 1" --foreground "$c_err" "✗ $*"
  else
    echo "ERROR $*" >&2
  fi
}
die() {
  fail "$*"
  exit 1
}

# Show the exact command before running it.
show_cmd() { note "\$ $*"; }

confirm() {
  ((assume_yes)) && return 0
  if is_interactive; then
    gum confirm "$@"
  else
    die "Confirmation needed for: $1 (pass --yes when not interactive)"
  fi
}

# gum choose with the shared look: padding, a bold header, and options given
# as "label<TAB>value" (the value is printed). Usage: choose HEADER [FLAGS] OPTIONS
choose() {
  local header
  header=$(CLICOLOR_FORCE=1 gum style --bold --margin "0 0 1 0" --foreground "$c_alt" "$1")
  shift
  gum choose --padding="1 2" --label-delimiter=$'\t' --header "$header" "$@"
}

# spin [--show] TITLE CMD...: run CMD under a spinner and print its output once
# it finishes: always with --show, otherwise only on failure. The output also
# stays in $tmpdir/spin.log.
spin() {
  local show=0
  if [[ $1 == --show ]]; then
    show=1
    shift
  fi
  local title=$1
  shift
  local log="$tmpdir/spin.log" rc=0
  if is_tty_out; then
    # Redirect inside the spinner: gum draws on its own stderr.
    # shellcheck disable=SC2016
    gum spin --title "$title" -- "$BASH" -c '"$@" >"$0" 2>&1' "$log" "$@" || rc=$?
  else
    echo "$title" >&2
    "$@" >"$log" 2>&1 || rc=$?
  fi
  if ((rc || show)) && [[ -s $log ]]; then
    if is_tty_out; then
      printf '\e[38;5;%sm' "$c_dim" >&2
      sed 's/^/    /' "$log" >&2
      printf '\e[0m' >&2
    else
      cat "$log" >&2
    fi
  fi
  return "$rc"
}

# Ask for the sudo password while the terminal is visible, so a command under
# a spinner can reuse the cached credentials instead of prompting unseen.
sudo_ready() { sudo -v; }

# progress_bar: read "done<TAB>total<TAB>step" lines and redraw one status line
# with a bar, the counts and the current step. The line is cleared at the end.
progress_bar() {
  local cols width=24 bar_done bar_todo counts room i n finished total step
  cols=$(stty size </dev/tty 2>/dev/null | cut -d' ' -f2) || true
  [[ $cols =~ ^[0-9]+$ ]] && ((cols >= 40)) || cols=80
  printf '\e[?25l' >&2
  while IFS=$'\t' read -r finished total step; do
    ((finished > total)) && finished=$total
    n=0
    ((total > 0)) && n=$((finished * width / total))
    bar_done="" bar_todo=""
    for ((i = 0; i < width; i++)); do
      if ((i < n)); then bar_done+="━"; else bar_todo+="━"; fi
    done
    counts=""
    ((total > 0)) && counts="$finished/$total"
    room=$((cols - width - ${#counts} - 6))
    ((room < 1)) && room=1
    ((${#step} > room)) && step="${step:0:room-1}…"
    printf '\r\e[K  \e[38;5;%sm%s\e[38;5;%sm%s\e[0m %s  \e[38;5;%sm%s\e[0m' \
      "$c_accent" "$bar_done" "$c_dim" "$bar_todo" "$counts" "$c_dim" "$step" >&2
  done
  printf '\r\e[K\e[?25h' >&2
}

# nix_progress: turn `nix --log-format internal-json` events on stdin into the
# lines progress_bar reads. Builds and downloads both count towards the total;
# the step is the most recently started activity still running, or else the
# last one shown.
nix_progress() {
  # shellcheck disable=SC2016
  jq -nrR --unbuffered '
    def name: sub("^/nix/store/[a-z0-9]{32}-"; "") | sub("\\.drv$"; "");
    def step:
      if .type == 105 then "building " + (.fields[0] | name)
      elif .type == 100 then "fetching " + (.fields[0] | name)
      elif .type == 0 and (.text // "") != "" then .text
      else empty end;
    foreach (inputs | ltrimstr("@nix ") | fromjson? // empty) as $e (
      {kind: {}, prog: {}, active: {}, step: "evaluating", line: null, last: null};
      ($e.id | tostring) as $id
      | if $e.action == "start" then
          .kind[$id] = $e.type
          | ([$e | step] | first) as $l
          | if $l then .active[$id] = $l else . end
        elif $e.action == "stop" then
          del(.kind[$id]) | del(.active[$id])
        elif $e.action == "result" and $e.type == 105
          and (.kind[$id] == 104 or .kind[$id] == 103) then
          .prog[$id] = $e.fields
        else . end
      | .step = ((.active | to_entries | max_by(.key | tonumber) | .value) // .step)
      | .last = .line
      | .line = ([.prog[][0]] | add // 0 | tostring) + "\t"
          + ([.prog[][1]] | add // 0 | tostring) + "\t"
          + .step;
      select(.line != .last) | .line
    )'
}

table() {
  # TSV with a header row on stdin.
  if is_tty_out; then
    gum table --print --separator=$'\t' --border rounded >&2
  else
    column -t -s $'\t' >&2
  fi
}

pause() {
  is_interactive || return 0
  style --foreground "$c_dim" --margin "1 0 0 1" "press enter to return to the menu"
  read -r _ || true
}

human_age() {
  local secs=$(($(date +%s) - $1))
  if ((secs < 3600)); then
    echo "$((secs / 60))m ago"
  elif ((secs < 86400)); then
    echo "$((secs / 3600))h ago"
  else
    echo "$((secs / 86400))d ago"
  fi
}

fmt_date() { date -d "@$1" '+%Y-%m-%d %H:%M'; }

# --- Flake helpers -----------------------------------------------------------

require_flake() {
  [[ -n $flake ]] ||
    die "No flake configured: set programs.nixie.flake, \"flake = <path>\" in $config_file, or NIXIE_FLAKE"
  [[ -f $flake/flake.nix ]] || die "No flake at $flake (from $flake_source)"
}

require_nixos() {
  [[ $mode == nixos ]] || die "This action needs NixOS; $host uses standalone Home Manager"
}

# Files that exist in the checkout but not in Git's view are invisible to a
# Git-backed flake evaluation, even though jj tracks them.
check_flake_visibility() {
  local missing
  missing=$(git -C "$flake" ls-files --others --exclude-standard 2>/dev/null || true)
  [[ -z $missing ]] && return 0
  warn "These files are not visible to the flake (not in Git's index):"
  while IFS= read -r f; do note "$f"; done <<<"$missing"
  note "Make them visible with: git -C $flake add --intent-to-add <file>"
}

# Root inputs of a lock file as TSV: name, lastModified, revision.
lock_inputs() {
  jq -r '
    . as $l
    | .nodes.root.inputs
    | to_entries[]
    | ($l.nodes[.value | if type == "array" then .[0] else . end].locked // {}) as $k
    | [.key, ($k.lastModified // 0), (($k.rev // $k.narHash // "")[0:7])]
    | @tsv
  ' "$1"
}

input_names() { lock_inputs "$flake/flake.lock" | cut -f1; }

# build ATTR: build a flake attribute and print its store path. On a terminal
# a progress bar stands in for Nix's log, whose errors are shown on failure.
build() {
  local attr=$1
  local link log="$tmpdir/build.log"
  link="$tmpdir/result-$(date +%s%N)"
  show_cmd "nix build $flake#$attr"
  if is_tty_out; then
    if ! nix build --log-format internal-json --out-link "$link" "$flake#$attr" 2>&1 >/dev/null |
      tee "$log" | nix_progress | progress_bar; then
      jq -rR 'ltrimstr("@nix ") | (fromjson? // {action: "msg", level: 0, msg: .})
        | select(.action == "msg" and .level <= 1) | .msg' "$log" >&2
      return 1
    fi
  else
    nix build -L --out-link "$link" "$flake#$attr" >&2 || return 1
  fi
  readlink -f "$link"
}

diff_closures() {
  local old=$1 new=$2
  if [[ ! -e $old ]]; then
    note "Nothing to compare against ($old is missing)"
    return 0
  fi
  if [[ $(readlink -f "$old") == "$new" ]]; then
    ok "No changes: the new build is identical to the running one"
    return 1
  fi
  nvd diff "$old" "$new" >&2
}

# --- Commands ----------------------------------------------------------------

cmd_status() {
  require_flake
  section "Checkout"
  if [[ -d $flake/.jj ]]; then
    local summary changed
    summary=$(jj -R "$flake" log -r @ --no-graph --color never \
      -T 'change_id.shortest(8) ++ " " ++ if(description, description.first_line(), "(no description)")')
    changed=$(jj -R "$flake" diff --name-only | wc -l)
    note "@ $summary"
    if ((changed)); then
      warn "$changed file(s) changed in the working copy"
    else
      ok "Working copy matches its parent"
    fi
  else
    note "$(git -C "$flake" log -1 --format='%h %s')"
  fi
  check_flake_visibility

  section "Running"
  if [[ $mode == nixos ]]; then
    note "System  generation $(current_system_gen) → $(basename "$(readlink -f /run/current-system)")"
    if [[ $(readlink -f /run/current-system) != $(readlink -f "$system_profile") ]]; then
      warn "The booted/running system differs from the default boot generation"
    fi
  fi
  if [[ -e $current_home ]]; then
    note "Home    $(basename "$(readlink -f "$current_home")") ($(human_age "$(stat -c %Y "$current_home")"))"
  fi
  note "Store   $(df -h /nix | awk 'NR == 2 { print $4 " free of " $2 }')"

  section "Inputs"
  {
    printf 'Input\tUpdated\tAge\tRevision\n'
    while IFS=$'\t' read -r name modified rev; do
      if ((modified)); then
        printf '%s\t%s\t%s\t%s\n' "$name" "$(fmt_date "$modified")" "$(human_age "$modified")" "$rev"
      else
        printf '%s\t-\t-\t%s\n' "$name" "$rev"
      fi
    done < <(lock_inputs "$flake/flake.lock" | sort -t$'\t' -k2,2n)
  } | table
}

cmd_update() {
  require_flake
  local inputs=()
  while (($#)); do
    case $1 in
    -n | --dry-run) dry_run=1 ;;
    -*) die "Unknown option for update: $1" ;;
    *) inputs+=("$1") ;;
    esac
    shift
  done

  if ((${#inputs[@]} == 0)) && is_interactive && ((! assume_yes)); then
    local choice
    choice=$(choose "Update which inputs?" "All inputs"$'\t'all "Pick inputs…"$'\t'pick) || return 0
    if [[ $choice == pick ]]; then
      local options=()
      while IFS=$'\t' read -r name modified _; do
        if ((modified)); then
          options+=("$name ($(human_age "$modified"))"$'\t'"$name")
        else
          options+=("$name"$'\t'"$name")
        fi
      done < <(lock_inputs "$flake/flake.lock")
      local picked
      picked=$(choose "Space selects, enter confirms" --no-limit "${options[@]}") || return 0
      [[ -n $picked ]] && mapfile -t inputs <<<"$picked"
      ((${#inputs[@]})) || {
        note "Nothing selected"
        return 0
      }
    fi
  fi

  local known
  known=$(input_names)
  for i in "${inputs[@]}"; do
    grep -qxF "$i" <<<"$known" || die "Unknown input: $i"
  done

  section "Updating ${inputs[*]:-all inputs}"
  local new="$tmpdir/flake.lock"
  spin "Fetching newer revisions…" \
    nix flake update --flake "$flake" --output-lock-file "$new" "${inputs[@]}"

  local changes
  changes=$(LC_ALL=C join -t$'\t' \
    <(lock_inputs "$flake/flake.lock" | LC_ALL=C sort -t$'\t' -k1,1) \
    <(lock_inputs "$new" | LC_ALL=C sort -t$'\t' -k1,1) |
    awk -F'\t' '$2 != $4 || $3 != $5')
  if [[ -z $changes ]]; then
    ok "Already up to date"
    return 0
  fi

  {
    printf 'Input\tFrom\tTo\tRevisions\n'
    while IFS=$'\t' read -r name old_t old_r new_t new_r; do
      local from=- to=-
      ((old_t)) && from=$(fmt_date "$old_t")
      ((new_t)) && to=$(fmt_date "$new_t")
      printf '%s\t%s\t%s\t%s → %s\n' "$name" "$from" "$to" "$old_r" "$new_r"
    done <<<"$changes"
  } | table

  if ((dry_run)); then
    note "Dry run: flake.lock left unchanged"
    return 0
  fi
  confirm "Write these changes to flake.lock?" || return 0
  cp "$new" "$flake/flake.lock"
  ok "flake.lock updated"

  if is_interactive && ((! assume_yes)) && gum confirm "Rebuild and switch now?"; then
    cmd_rebuild all switch
  fi
}

# rebuild [all|home|nvim|nvim-lite] [switch|boot|test|build|dry]
cmd_rebuild() {
  require_flake
  local target="" action=""
  while (($#)); do
    case $1 in
    all | system | home | nvim | nvim-lite) target=$1 ;;
    switch | boot | test | build) action=$1 ;;
    dry | --dry | --dry-run | -n) action=dry ;;
    --boot | --test | --build) action=${1#--} ;;
    *) die "Unknown argument for rebuild: $1" ;;
    esac
    shift
  done
  [[ $target == system ]] && target=all

  if [[ -z $target ]]; then
    if is_interactive && ((! assume_yes)); then
      local options=()
      if [[ $mode == nixos ]]; then
        options+=("Everything (system + home)"$'\t'all "Home only"$'\t'home)
      else
        options+=("Home"$'\t'home)
      fi
      options+=("Neovim (standalone build)"$'\t'nvim "Neovim lite"$'\t'nvim-lite)
      target=$(choose "Rebuild what?" "${options[@]}") || return 0
    else
      target=all
    fi
  fi
  [[ $target == all && $mode == home ]] && target=home

  if [[ -z $action ]]; then
    if [[ $target == nvim* ]]; then
      action=build
    elif is_interactive && ((! assume_yes)); then
      local options=("Switch now"$'\t'switch)
      if [[ $target == all ]]; then
        options+=("Activate at next boot"$'\t'boot "Test (until reboot, no boot entry)"$'\t'test)
      fi
      options+=("Build only"$'\t'build "Dry activation (show what would change)"$'\t'dry)
      action=$(choose "How?" "${options[@]}") || return 0
    else
      action=switch
    fi
  fi

  case $target in
  all) rebuild_system "$action" ;;
  home) rebuild_home "$action" ;;
  nvim | nvim-lite) rebuild_nvim "$target" ;;
  esac
}

rebuild_system() {
  local action=$1
  require_nixos
  [[ $action == dry ]] && action=dry-activate
  check_flake_visibility

  section "Building $host"
  local out
  out=$(build "$system_attr") || return 1
  ok "Built $(basename "$out")"

  section "Changes against the running system"
  if ! diff_closures /run/current-system "$out"; then
    # Identical to what runs; only "boot" can still be meaningful.
    [[ $action == boot ]] || return 0
  fi

  [[ $action == build ]] && return 0
  confirm "Run '$action' for this system?" || return 0
  section "Activating ($action)"
  show_cmd "nixos-rebuild $action --store-path $out --sudo"
  sudo_ready
  spin --show "Running $action…" nixos-rebuild "$action" --store-path "$out" --sudo
  ok "System $action finished"
}

rebuild_home() {
  local action=$1
  check_flake_visibility

  section "Building home for $user"
  local out
  out=$(build "$home_attr") || return 1
  ok "Built $(basename "$out")"

  section "Changes against the active home"
  diff_closures "$current_home" "$out" || return 0

  case $action in
  build) return 0 ;;
  switch | dry) ;;
  *) die "Home Manager cannot '$action'; use switch, build or dry" ;;
  esac

  if [[ $mode == nixos && $action == switch ]]; then
    warn "Home Manager is part of the NixOS system here. This home switch lasts"
    warn "until the next boot or full system switch, which restore the home"
    warn "generation built into the system. Run 'nixie rebuild all' to keep it."
  fi

  local args=()
  # Under the NixOS module, the generation is tracked by a GC root instead of a
  # Home Manager profile; driver version 1 activates without touching profiles.
  [[ $mode == nixos ]] && args+=(--driver-version 1)
  if [[ $action == dry ]]; then
    show_cmd "DRY_RUN=1 $out/activate ${args[*]}"
    spin --show "Simulating activation…" env DRY_RUN=1 "$out/activate" "${args[@]}"
  else
    confirm "Activate this home generation?" || return 0
    section "Activating home"
    show_cmd "$out/activate ${args[*]}"
    spin --show "Activating…" "$out/activate" "${args[@]}"
    ok "Home activated"
  fi
}

rebuild_nvim() {
  local variant=$1
  section "Building $variant"
  local out
  out=$(build "$variant") || return 1
  ok "Built $out"
  note "Run it with: nix run $flake#$variant"
  if is_interactive && ((! assume_yes)) && gum confirm "Open it now (scratch state)?"; then
    local scratch="$tmpdir/nvim"
    env XDG_CONFIG_HOME="$scratch/config" XDG_DATA_HOME="$scratch/data" \
      XDG_STATE_HOME="$scratch/state" XDG_CACHE_HOME="$scratch/cache" \
      "$out/bin/nvim"
  fi
}

cmd_diff() {
  local out
  require_flake
  check_flake_visibility
  if [[ $mode == nixos ]]; then
    section "System: running → checkout"
    out=$(build "$system_attr") || return 1
    diff_closures /run/current-system "$out" || true
  fi
  section "Home: active → checkout"
  out=$(build "$home_attr") || return 1
  diff_closures "$current_home" "$out" || true
}

cmd_generations() {
  require_nixos
  section "System generations"
  nixos-rebuild list-generations --json |
    jq -r '
      ["Gen", "Built", "NixOS", "Kernel", ""],
      (.[] | [(.generation | tostring), .date[0:16], .nixosVersion, .kernelVersion,
              (if .current then "● current" else "" end)])
      | @tsv' |
    table
}

cmd_rollback() {
  require_nixos
  local current gens target
  current=$(current_system_gen)
  gens=$(nixos-rebuild list-generations --json |
    jq -r '.[] | select(.current | not) | "\(.generation)\t\(.date[0:16])  \(.nixosVersion)"')
  [[ -n $gens ]] || die "No other generations to roll back to"

  if (($#)); then
    target=$1
  elif is_interactive; then
    local options=()
    while IFS=$'\t' read -r g desc; do
      options+=("$g  $desc"$'\t'"$g")
    done <<<"$gens"
    target=$(choose "Roll back from generation $current to:" "${options[@]}") || return 0
  else
    target=$(head -1 <<<"$gens" | cut -f1)
  fi

  local path="$system_profile-$target-link"
  [[ -e $path ]] || die "Generation $target does not exist"
  path=$(readlink -f "$path")

  section "Changes: running → generation $target"
  diff_closures /run/current-system "$path" || return 0
  confirm "Switch to generation $target? (it becomes a new generation)" || return 0
  show_cmd "nixos-rebuild switch --store-path $path --sudo"
  sudo_ready
  spin --show "Switching to generation $target…" nixos-rebuild switch --store-path "$path" --sudo
  ok "Now running the configuration of generation $target"
}

current_system_gen() {
  local gen
  gen=$(readlink "$system_profile")
  gen=${gen#system-}
  echo "${gen%-link}"
}

# system_doomed SPEC: system generations `nix-env --delete-generations SPEC`
# would remove. Its own --dry-run needs the root-owned profile lock, so this
# mirrors its rules: "+N" keeps the newest N, "Nd" keeps everything newer
# than N days plus the newest generation older than that. Current always stays.
system_doomed() {
  local spec=$1 current gens g i=0 cutoff kept_one=0
  current=$(current_system_gen)
  mapfile -t gens < <(find /nix/var/nix/profiles -maxdepth 1 -name 'system-*-link' -printf '%f\n' |
    sed 's/^system-\([0-9]*\)-link$/\1/' | sort -rn)
  if [[ $spec == +* ]]; then
    for g in "${gens[@]}"; do
      ((i++ < ${spec#+})) && continue
      [[ $g == "$current" ]] || echo "$g"
    done
  else
    cutoff=$(($(date +%s) - ${spec%d} * 86400))
    for g in "${gens[@]}"; do
      (($(stat -c %Y "$system_profile-$g-link") < cutoff)) || continue
      if ((kept_one)); then
        [[ $g == "$current" ]] || echo "$g"
      else
        kept_one=1
      fi
    done
  fi
}

# clean [--keep N | --older-than Nd | --gc-only] [--optimise] [--dry-run]
cmd_clean() {
  local spec="" optimise=0
  while (($#)); do
    case $1 in
    --keep)
      [[ ${2:-} =~ ^[0-9]+$ ]] || die "--keep needs a number"
      spec="+$2"
      shift
      ;;
    --older-than)
      [[ ${2:-} =~ ^[0-9]+d$ ]] || die "--older-than needs a value like 14d"
      spec=$2
      shift
      ;;
    --gc-only) spec=none ;;
    --optimise | --optimize) optimise=1 ;;
    -n | --dry-run) dry_run=1 ;;
    *) die "Unknown option for clean: $1" ;;
    esac
    shift
  done

  if [[ -z $spec ]]; then
    if is_interactive && ((! assume_yes)); then
      spec=$(choose "Which generations should go?" \
        "Keep the newest 5"$'\t'+5 \
        "Keep the newest 10"$'\t'+10 \
        "Older than 14 days"$'\t'14d \
        "Older than 30 days"$'\t'30d \
        "None, only collect garbage"$'\t'none) || return 0
      gum confirm "Also deduplicate the store (slow)?" --default=false && optimise=1
    else
      spec=+10
    fi
  fi

  local profiles=()
  for p in "${user_profiles[@]}"; do [[ -e $p ]] && profiles+=("$p"); done

  local system_deleted=0
  if [[ $spec != none ]]; then
    section "Generations to delete ($spec)"
    local preview="" out
    if [[ $mode == nixos ]]; then
      out=$(system_doomed "$spec" | paste -sd' ')
      if [[ -n $out ]]; then
        system_deleted=1
        preview+="system: $out"$'\n'
      fi
    fi
    for p in "${profiles[@]}"; do
      out=$(nix-env -p "$p" --delete-generations "$spec" --dry-run 2>&1 || true)
      if grep -q 'would remove' <<<"$out"; then
        preview+="$(basename "$p"): $(grep -o 'generation [0-9]*' <<<"$out" | cut -d' ' -f2 | paste -sd' ')"$'\n'
      fi
    done
    if [[ -z $preview ]]; then
      ok "No generations match"
    else
      while IFS= read -r line; do [[ -n $line ]] && note "$line"; done <<<"$preview"
    fi
  fi

  section "Garbage collection"
  local dead
  spin "Looking for unreferenced store paths…" nix-store --gc --print-dead
  dead=$(grep -c '^/nix/store/' "$tmpdir/spin.log" || true)
  note "$dead store path(s) are unreferenced right now (more after deleting generations)"

  if ((dry_run)); then
    note "Dry run: nothing deleted"
    return 0
  fi
  confirm "Delete these generations and collect garbage?" || return 0

  if [[ $spec != none ]]; then
    if ((system_deleted)); then
      show_cmd "sudo nix-env -p $system_profile --delete-generations $spec"
      sudo_ready
      spin --show "Deleting system generations…" sudo nix-env -p "$system_profile" --delete-generations "$spec"
    fi
    for p in "${profiles[@]}"; do
      nix-env -p "$p" --delete-generations "$spec" >/dev/null
    done
  fi

  spin "Collecting garbage…" nix store gc
  local freed
  freed=$(grep -E 'freed' "$tmpdir/spin.log" | tail -1 || true)
  ok "${freed:-Garbage collected}"

  if ((optimise)); then
    spin "Deduplicating the store…" nix store optimise
    ok "Store deduplicated"
  fi

  # Removed generations stay in the boot menu until its entries are rewritten.
  if ((system_deleted)); then
    section "Boot menu"
    if confirm "Refresh boot menu entries now?"; then
      show_cmd "sudo /run/current-system/bin/switch-to-configuration boot"
      sudo_ready
      spin --show "Rewriting boot entries…" sudo /run/current-system/bin/switch-to-configuration boot
      ok "Boot entries refreshed"
    else
      note "They are refreshed with the next switch or boot activation"
    fi
  fi
}

cmd_check() {
  require_flake
  check_flake_visibility
  section "Checking the flake"
  spin "Evaluating every output…" nix flake check --no-build --no-write-lock-file "$flake"
  ok "Flake evaluates cleanly"
}

cmd_edit() {
  require_flake
  (cd "$flake" && "${VISUAL:-${EDITOR:-nvim}}" .)
}

usage() {
  cat <<EOF
nixie $nixie_version — manage this NixOS / Home Manager flake

Usage: nixie [--yes] [command] [args]

Without a command, nixie opens an interactive menu.

Commands:
  status                      Checkout state, running generations, input ages
  update [INPUT…] [--dry-run] Update all or selected flake inputs (flake.lock)
  rebuild [TARGET] [ACTION]   Build, show a package diff, confirm, activate
                                TARGET: all (default), home, nvim, nvim-lite
                                ACTION: switch (default), boot, test, build, dry
  diff                        Build without activating, compare with running
  clean [OPTIONS]             Delete old generations and collect garbage
                                --keep N | --older-than 14d | --gc-only
                                --optimise  --dry-run
  generations                 List system generations (NixOS)
  rollback [GEN]              Switch to an earlier system generation (NixOS)
  check                       nix flake check --no-build
  edit                        Open the flake in \$VISUAL/\$EDITOR
  help                        Show this text

Options:
  -y, --yes                   Skip confirmations (required when not on a TTY)

Environment:
  NIXIE_FLAKE                 Flake checkout (now: ${flake:-unset}${flake_source:+, from $flake_source})
  NIXIE_HOST                  Host name to build (now: $host)
  NO_COLOR                    Plain output

Configuration ($config_file):
  flake = <path>              Flake checkout, used when NIXIE_FLAKE is unset;
                                Home Manager writes it from programs.nixie.flake

On NixOS, Home Manager is part of the system. "rebuild home" activates the new
home directly; the next boot or full switch restores the system's own copy.
EOF
}

# --- Menu --------------------------------------------------------------------

menu() {
  while true; do
    is_tty_out && printf '\033[H\033[2J' >&2
    banner
    local options=(
      "Status"$'\t'status
      "Update inputs"$'\t'update
      "Rebuild"$'\t'rebuild
      "Diff checkout against running"$'\t'diff
      "Clean up"$'\t'clean
    )
    [[ $mode == nixos ]] && options+=("Generations"$'\t'generations "Roll back"$'\t'rollback)
    options+=("Check flake"$'\t'check "Edit configuration"$'\t'edit "Quit"$'\t'quit)

    local choice
    choice=$(choose "What now?" "${options[@]}") || return 0
    [[ $choice == quit ]] && return 0
    # A subshell keeps a failing action from ending the menu.
    ("cmd_$choice") || fail "$choice failed"
    pause
  done
}

# --- Main --------------------------------------------------------------------

main() {
  local args=()
  while (($#)); do
    case $1 in
    -y | --yes) assume_yes=1 ;;
    -h | --help) args+=(help) ;;
    *) args+=("$1") ;;
    esac
    shift
  done
  set -- "${args[@]}"

  if (($# == 0)); then
    if is_interactive; then
      require_flake
      menu
      return
    fi
    usage
    return
  fi

  local cmd=$1
  shift
  case $cmd in
  status | update | rebuild | diff | clean | generations | rollback | check | edit)
    banner
    "cmd_$cmd" "$@"
    ;;
  switch) banner && cmd_rebuild all switch "$@" ;;
  help) usage ;;
  version | --version) echo "nixie $nixie_version" ;;
  *)
    usage >&2
    exit 2
    ;;
  esac
}

main "$@"
