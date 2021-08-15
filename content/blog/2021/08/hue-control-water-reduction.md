---
title: "Reducing Water Use"
date: 2021-08-15T04:41:19-06:00
draft: false
description: "Preserve our natural resources, one drop at a time"
---

Using code to interact with the physical world is a new goal for me. I recently watched the [Everyday Astronaut Starbase tour with Elon Musk](https://www.youtube.com/watch?v=t705r8ICkRw). During the Tour, Elon talked about how designing solutions is one of the easiest steps in developing a product. The more challenging step is to build the manufacturing systems to make the product. By writing code that interacts with the physical world, I'm taking a step in that direction.

In 2019 I wrote a Python application that monitors the Hue lights installed in my apartment's bathrooms. If the bathroom light is on for longer than 10 minutes, the light will blink to alert the bathroom user. By alerting the user to how long they're spending in the bathroom, they can try to take shorter showers and reduce their water use.

I have pondered more direct or accurate ways to reduce water use. I found my favorite way to reduce the amount of water used by the shower in a British hostel. This shower used a spring-loaded engagement button to turn the water on. The water would turn on when the button was pressed and slowly release itself, which would turn off the water after about 3 minutes. I enjoyed the physicality of the interaction with the button; it gave me a sense of how much water I had used.

I cannot modify the fixtures in my apartment, so I've thought of other options to monitor water use. One of the most accurate would be to use vibration sensors to detect when the water turns on. Monitoring vibrations in the showerhead would give me a more precise measurement of water use. To make this possible, I'd have to purchase more sensors and microcontrollers to complete the project.

Instead, I'm opting for a simpler solution with the Hue lights. My partner made me turn off the original Python application because of how annoying the alert mode was. Hue has two alert modes for its lights: a single blink or blinking for 15 seconds. I found that humans could easily miss a single blink if it aligned with their natural eye blinking, so I felt that the longer strobing was necessary. However, 15 seconds of blinking every few minutes is overkill and renders the shower taker utterly annoyed.

I'm pretty happy with my rewrite of the Python application into Golang. I can use Go's concurrency patterns to monitor more aspects of the lights and act on them simultaneously. In the original application, I could only monitor how long a light was on for and alert when it was too long. With the rewrite, I can also monitor how long a light is alerting and turn it off after only a few seconds. Hopefully, this will help reduce water use and improve the user experience.

Github: [hue-control](https://github.com/nateinaction/hue-control)
