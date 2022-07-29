import conans

class cmakeHelper(conans.ConanFile):
    # Package and Src information
    name = "cmakeHelper"
    version = "0.1"

    author = "ALi Ibrahim"
    url = ""
    license = ""
    description = ""

    scm = {
        "type": "git",
        "url": "auto",
        "revision": "auto",
        "subfolder": "."
    }

    def build(self):
        pass

    def package(self):
        self.copy("*.cmake", dst="", src="")
