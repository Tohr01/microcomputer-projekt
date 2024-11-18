# FPGA <> Arduino connection

## How is it possible?

### Connection

- **GPIO (General Purpose Input/Output) Pins**: connect them with the pins on the FPGA via pins or a unique PCB (Printed Circuit Board)
- **Shields**: Ports on FPGA shields, which are pre-built modules, allow for a direct connection to the Arduino board via Arduino shields

### Implementation

- FPGA board support package for the Arduino
  - By selecting “Board” from the Arduino IDE’s “Tools” menu, followed by “Boards Manager,” you can install the board support package. Find the FPGA board you’re using in the Boards Manager, then select “Install.”

## What instructions do we need for this on the fpga?

- instructions that are used for sending numbers to the arduino via the GPIO's
  - [ ... ]

## References

- [How to program Arduino FPGA](https://www.raypcb.com/arduino-fpga/#:~:text=Connecting%20an%20FPGA%20to%20an%20Arduino%20Board&text=GPIO%20Pins%3A%20Using%20the%20General,can%20interface%20with%20external%20electronics)