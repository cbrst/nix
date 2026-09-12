{ ... }:
{
  # Both editors use the same fallbacks; project-local configuration wins.
  xdg.configFile."mago.toml".text = ''
    [formatter]
    tab-width = 2
    single-quote = false
  '';
  xdg.configFile."rumdl/rumdl.toml".text = ''
    [MD013]
    line-length = 80
    reflow = true
    reflow-mode = "normalize"
    code-blocks = false
    tables = false
    headings = false
    math-blocks = false
  '';
}
