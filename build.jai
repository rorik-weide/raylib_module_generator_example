/* 
# Build
  
  { Raylib } bindings generator works on Windows/Linux. The only function which matters is { generate_raylib_module }.
*/

#scope_file

#import "Basic";
#import "Compiler";
#import "File_Utilities";
#import "File";
#import "Bindings_Generator";

#load "config.jai";

MODULE_NAME :: "raylib";

#if OS == .WINDOWS {
  LIBRARY_NAME     :: "raylib";
  VENDOR_DIRECTORY :: "vendor/raylib-4.5.0_win64_msvc16";
  LIBRARY_FILES    :: string.["raylib.lib", "raylib.dll", "raylibdll.lib"];
} else #if OS == .LINUX {
  LIBRARY_NAME     :: "libraylib";
  VENDOR_DIRECTORY :: "vendor/raylib-4.5.0_linux_amd64";
  LIBRARY_FILES    :: string.["libraylib.a", "libraylib.so", "libraylib.so.4.5.0", "libraylib.so.450"];
} else {
  #assert false;
}

// Build the project based on configuration from { config.jai }.
#run {
  // Settings for build during compilation.
  set_build_options_dc(.{
    do_output= false,
    write_added_strings= false
  });

  // Generate Raylib module if it does not exist.
  if !file_exists("local_modules/raylib") {
    generate_raylib_module(MODULE_NAME, VENDOR_DIRECTORY);
  }

  workspace := compiler_create_workspace(PROJECT_NAME);
  if !workspace {
    print("[build] workspace creation for: % failed!\n", PROJECT_NAME);
    return;
  }

  // Print the status of the build.
  {
    status: String_Builder;
    print_to_builder(*status, "\n--\n");
    print_to_builder(*status, "name: \t\t%\n", PROJECT_NAME);
    print_to_builder(*status, "version: \t%.%\n", PROJECT_VERSION_MAJOR, PROJECT_VERSION_MINOR);
    print_to_builder(*status, "build_mode: \t%\n", PROJECT_BUILD_MODE);
    print_to_builder(*status, "--\n");
    print(builder_to_string(*status));
  }

  if PROJECT_BUILD_MODE == .DEBUG {
    project_build_debug(workspace);
  } else {
    log_error("[build] Build path not implemented!");
    exit(1);
  }
}


// Build the project in debug mode.
project_build_debug :: (workspace: Workspace) {
  // Configure the workspace for debug build.
  options := get_build_options(workspace);

  options.output_executable_name  = PROJECT_NAME;
  options.backend                 = .X64;
  options.stack_trace             = true;
  options.intermediate_path       = BUILD_OUTPUT_DIRECTORY;
  options.output_path             = BUILD_OUTPUT_DIRECTORY;
  options.output_type             = .EXECUTABLE;
  options.write_added_strings     = false;

  set_optimization(*options, .DEBUG);

  // Add `modules` to import path.
  new_import_path: [..]string;
  array_add(*new_import_path, ..options.import_path);
  array_add(*new_import_path, LOCAL_MODULE_IMPORT_DIRECTORY);
  options.import_path = new_import_path;

  set_build_options(options, workspace);

  // Add entry point and config to the build.
  add_build_file("src/main.jai", workspace);
  add_build_file("config.jai", workspace);
}


// Use to generate module from the given raylib release.
generate_raylib_module :: (module_name: string, raylib_path: string) {
  using options: Generate_Bindings_Options;
  strip_flags                         = 0;
  generate_compile_time_struct_checks = true;
  alias_original_enum_names           = false;
  c_enum_emulation                    = false;
  generate_library_declarations       = false;

  // Add definitions for things that are missing in the { module.jai } header.
  header = #string MODULE_HEADER
va_list :: *void;
  MODULE_HEADER

  // Link against system libraries we need in the { module.jai } footer (order matters).
  #if OS == .WINDOWS {
  footer = #string MODULE_FOOTER
user32  :: #system_library,link_always "user32";
gdi32   :: #system_library,link_always "gdi32";
shell32 :: #system_library,link_always "shell32";
winmm   :: #system_library,link_always "winmm";
raylib  :: #library "lib/windows/raylib";
MODULE_FOOTER
  } else if OS == .LINUX {
  footer = #string MODULE_FOOTER
// Ensure we link to libm for math functions
#library,system,link_always "libm";
raylib  :: #library "lib/linux/raylib";
MODULE_FOOTER
  }

  // Add { Raylib } files to the generator.
  raylib_lib_directory     := tprint("%/lib", raylib_path);
  raylib_include_directory := tprint("%/include", raylib_path);

  array_add(*libpaths, raylib_lib_directory);
  array_add(*libnames, LIBRARY_NAME);
  array_add(*include_paths, raylib_include_directory);
  array_add(*source_files, ..string.["raylib.h", "raymath.h", "rlgl.h"]);
  array_add(*system_include_paths, GENERATOR_DEFAULT_SYSTEM_INCLUDE_PATH);

  // Generate module directory.
  raylib_module_directory     := tprint("%/%", LOCAL_MODULE_IMPORT_DIRECTORY, module_name);
  #if OS == .WINDOWS {
    raylib_module_lib_directory := tprint("%/lib/windows", raylib_module_directory);
  } else #if OS == .LINUX {
    raylib_module_lib_directory := tprint("%/lib/linux", raylib_module_directory);
  }
  raylib_module_file          := tprint("%/module.jai", raylib_module_directory);

  make_directory_if_it_does_not_exist(raylib_module_directory, true);

  // Generate bindings and save them as module.jai.
  generate_bindings(options, raylib_module_file);

  // Copy library files.
  make_directory_if_it_does_not_exist(raylib_module_lib_directory, true);

  for LIBRARY_FILES {
    file_src  := tprint("%/%", raylib_lib_directory, it);
    file_dest := tprint("%/%", raylib_module_lib_directory, it);

    copy_file(file_src, file_dest);
  }
}

