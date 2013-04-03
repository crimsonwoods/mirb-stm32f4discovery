mirb-stm32f4discovery
====

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

How to build
----

commands:

    $ cd mirb-stm32f4discovery
    $ make CROSS_COMPILE=arm-none-eabi-

License
----
MIT License
