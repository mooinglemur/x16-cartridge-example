# This is a simple example for creating a cartridge-based ROM program for the Commander X16

## To assemble:

```
cl65 -C custom.cfg src/main.s
```

This will create a file called `cart.bin` in the home directory


## To run:

```
x16emu -cartbin cart.bin
```
