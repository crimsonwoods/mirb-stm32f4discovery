mirb-stm32f4discovery
====

This project is __experimental__ implementation.

What's 'mruby'
----
See this: https://github.com/mruby/mruby

What's 'STM32F4 Discovery'
----
Very low-cost ARM processor board.<br/>
<img src="http://www.st.com/st-web-ui/static/active/en/fragment/product_related/rpn_information/board_photo/stm32f4_discovery.jpg"/><br/>
See this: http://www.st.com/web/en/catalog/tools/PF252419

Ready to build
----

1. get Codesourcery toolchain for ARM processor.
2. setup your environment variable PATH to make 'arm-none-eabi-gcc' can run.
3. get 'mruby' source code from <a href="https://github.com/mruby/mruby">github</a>.
4. build 'libmruby'.
5. get 'mirb-stm32f4discovery' source code.

commands:

    $ git clone https://github.com/mruby/mruby.git
    $ cd mruby
    $ vi build_config.rb
    $ make
    $ cd ..
    $ git clone https://github.com/crimsonwoods/mirb-stm32f4discovery.git

Edit 'build_config.rb'
----
edit your 'build_config.rb' to build 'libmruby'.<br/>
append cross-build settings.<br/>
like this:

    MRuby::CrossBuild.new('stm32f407') do |conf|
      toolchain :gcc
    
      conf.bins = %w() # target is just only 'libmruby.a'.
    
      conf.cc do |cc|
        cc.command = 'arm-none-eabi-gcc'
        cc.flags = %w(
          -MD -Os
          -mthumb -mcpu=cortex-m3 -nostdlib -mfloat-abi=softfp -mfpu=fpv4-sp-d16
          -fsigned-char -fno-inline -ffunction-sections -mlittle-endian)
        cc.defines = %w(
          MRB_HEAP_PAGE_SIZE=256
          POOL_PAGE_SIZE=1000
          MRB_STR_BUF_MIN_SIZE=32
          MRB_PARSER_BUF_SIZE=256)
      end
    
      conf.archiver do |ar|
        ar.command = 'arm-none-eabi-ar'
      end
    end

How to build
----

commands:

    $ cd mirb-stm32f4discovery
    $ make CROSS_COMPILE=arm-none-eabi-

if build succeeded, you will get an executable binary file 'build/mirb.bin'.

How to run
----
Use STM32 ST-LINK Utility.

License
----
MIT License
