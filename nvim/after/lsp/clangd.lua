return {
  filetypes = { "c", "cpp", "cc" },
  root_markers = {
    "compile_commands.json",  -- meson/cmake build
    "compile_flags.txt",
    ".clangd",
    "meson.build",
    "CMakeLists.txt",
    ".git",
  },
}
