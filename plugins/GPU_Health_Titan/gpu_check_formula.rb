class GpuCheckFormula < Formula
  homepage "https://github.com/AdamSimpson/IntervalCheck.git"
  url "none"

  concern for_version("dev") do
    included do
      url "none"

      module_commands do
        commands = [ "unload PrgEnv-gnu PrgEnv-pgi PrgEnv-cray PrgEnv-intel" ]

        commands << "load PrgEnv-gnu" if build_name =~ /gnu/
        commands << "swap gcc gcc/#{$1}" if build_name =~ /gnu([\d\.]+)/

        commands << "load cudatoolkit"
        commands << "load dynamic-link"
        commands << "load cmake3"
        commands << "load git"

        commands
      end

      def install
        module_list

	Dir.chdir "#{prefix}"
        system "rm -rf source"
        system "git clone https://github.com/AdamSimpson/IntervalCheck.git source"

	Dir.chdir "#{prefix}/source/plugins/GPU_Health_Titan"

        system "rm -rf build; mkdir build"
	Dir.chdir "build"
        system "cmake -DCUDA_TOOLKIT_ROOT_DIR=$CUDATOOLKIT_HOME -DCMAKE_INSTALL_PREFIX=#{prefix} .."
        system "make"
        system "make install"
      end
    end
  end

  modulefile <<-MODULEFILE.strip_heredoc
    #%Module
    proc ModulesHelp { } {
       puts stderr "<%= @package.name %> <%= @package.version %>"
       puts stderr ""
    }
    # One line description
    module-whatis "<%= @package.name %> <%= @package.version %>"

    module unload xalt
    module load cudatoolkit

    if { ![is-loaded interval_check] } {
      module load interval_check
    }

    setenv IC_PER_NODE true
    setenv GH_GPU_COUNT 1
    prepend-path IC_CALLBACKS gpu_health

    set PREFIX <%= @package.prefix %>

    prepend-path LD_LIBRARY_PATH $PREFIX/lib
    prepend-path LD_LIBRARY_PATH $PREFIX/plugins/lib

    prepend-path IC_PRELOAD $PREFIX/lib/libGPUhealthTitan.so

  MODULEFILE
end
