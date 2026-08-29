import subprocess
from gi.repository import GObject, Nautilus

class ContextActions(GObject.GObject, Nautilus.MenuProvider):
    def get_background_items(self, _current_folder):
        return []

    def get_file_items(self, files):
        if len(files) != 1:
            return []

        selected = files[0]
        location = selected.get_location()
        path = location.get_path() if location is not None else None
        if path is None:
            return []

        if selected.is_directory():
            item = Nautilus.MenuItem(
                name="ContextActions::OpenFolderSlideshow",
                label="Open Folder as Slideshow",
                tip="Play all media in this folder recursively and shuffled",
            )
            item.connect(
                "activate", self._launch, "@openFolderSlideshow@", path
            )
            return [item]

        mime_type = selected.get_mime_type()
        if mime_type is not None and mime_type.startswith("image/"):
            item = Nautilus.MenuItem(
                name="ContextActions::SetNoctaliaWallpaper",
                label="Set as Noctalia Wallpaper",
                tip="Replace the current Noctalia wallpaper with this image",
            )
            item.connect(
                "activate", self._launch, "@setNoctaliaWallpaper@", path
            )
            return [item]

        return []

    def _launch(self, _item, executable, path):
        subprocess.Popen(
            [executable, path],
            start_new_session=True,
        )
