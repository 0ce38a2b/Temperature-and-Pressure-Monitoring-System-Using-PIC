# Temperature-and-Pressure-Monitoring-System-Using-PIC
The system is developed to monitor temperature and pressure using the PIC16F877A microcontroller. Development and simulation of the system  are carried out using Proteus. More details are provided below.
# Design method
We implemented the temperature and pressure monitoring system
using PIC16F877A as the main controller, LM35 temperature sensor and MPX4115
pressure sensor to monitor the environment and display the values on 4-bit (BCD)
seven-segments displays respectively. The temperature value is at the max of 150
degrees and the measuring range for the pressure sensor is 15-115 Kpa. When a set
temperature or pressure is reached the system will light an LED to indicate an alarm.
# Program execution flow
The system is designed in sequential as shown in Fig. S1.
Calculation on TIMER0 is performed and the delay time is designed to be 25ms(based
on interrupt). The on-board ADC has a 10-bit resolution, but we only use the 8 bits
of the 10 bit ADC result as the last two bits are the least significant bits.
We extract the ADC result as per place using the subtraction and division algorithm
and send them for display. The functionality of “Read and display temperature/
pressure” is encapsulated in subroutines.
![image](https://user-images.githubusercontent.com/51925070/172604874-60ac9c78-ef74-4bfc-8043-407529c9f43d.png)
Figure S1: The left is the flow chart of the entire program. The right is the flow chart of the subroutine, “READ AND DISPLAY TEMPERATURE/PRESSURE”. 
# Signal conditioning circuits
The peripheral circuit is shown in Fig. S2. The
operational amplifiers are used as signal processing units to scale the input
signal(voltage) into the range of 0-5 volts which is appropriate for PIC16F877A.We
also use the op-amp as a comparetor.The output of the comparator will indicate
whether the temperature or pressure has reached a set value, and triggers the
controller to take an alarm response.
![image](https://user-images.githubusercontent.com/51925070/172604939-2b1303ec-9ed8-4d10-921d-03f726981634.png)
Figure S2: Circuit diagram of the temperature and pressure monitoring system
