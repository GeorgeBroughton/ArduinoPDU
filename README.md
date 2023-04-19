# ArduinoPDU
A small project for Arduino that uses a relay board coupled to an MCP23016 and an ATMEGA328P to create a desktop 12V switchable power distribution unit.

I use it for several things, and plan to expand it in the future to include mains appliances, and also do things like power usage monitoring.

# Planned Updates
 - Cross-platform Qt systray app that supports keyboard combinations.
 - Using a microcontroller that uses the USB protocol then creating drivers for it, instead of tunnelling RS232 over it.
 - Refactoring the powershell stuff so users can still use it once drivers are implemented.
 - Support for more serial communication with powered devices. Say you're powering a TV with RS232/485 support.
  - Plan is to implement tunneling for that so everything can be controlled from one place.
  - This will require people to make their own implementations for serial control of course since assigning COM ports across various operating systems is unreliable, and I would rather expose these as their own unique device names such that you can identify them easier. They will still function as character devices though.
