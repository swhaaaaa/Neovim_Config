return {
  filetypes = { "c", "cpp" },
  root_markers = {
    "compile_commands.json",  -- meson/cmake build
    "compile_flags.txt",
    ".clangd",
    "meson.build",
    "CMakeLists.txt",
    ".git",
  },
  -- Allow clangd to query Yocto/OpenBMC cross-compilers for built-in
  -- includes and defines. Covers arm-fb-linux-gnueabi (ventura2/OpenBMC)
  -- and any other arm cross-compiler under a Yocto sysroots tree.
  cmd = {
    "clangd",
    "--query-driver=**/arm-fb-linux-gnueabi-gcc*,**/arm-fb-linux-gnueabi-g++*,**/arm-*-linux-*-gcc*",
  },
}
