---
title: "City of Austin Quick District Lookup"
date: 2021-08-15T14:41:19-06:00
draft: false
description: "Helping Austin civil servants and leaders perform their jobs more efficiently"
---

When my partner was a Park Ranger, I enjoyed working with the Ranger team to develop a [random Austin park picker](https://github.com/nateinaction/austin-texas-parks). The park picker allowed the rangers to easily pick from Austin's 300+ parks during their daily patrols. We have also advertised this park picker to the [Austin Bark Rangers](http://www.austintexas.gov/page/bark-rangers) volunteers as a way to help them find new places to explore with their pets.

Now, my partner works for Austin Animal Services and fields calls from the public about interactions with Coyotes and other wild animals. Part of her job is to provide Austin City Council with the number and types of calls received from their district. Unfortunately, the call database does not correctly tag the district of the caller and only provides partial data about the caller's address. For example, only the street number, name, and zipcode are provided.

After a particularly frustrating day of looking up each partial address in the City's GIS database and manually entering the correct district into the call database, my partner asked for help automating this process. Lucky for me, the City has a decent GIS API that does much of the heavy lifting. The City's API will search for a partial address and return a list of possible matches with [Levenshtein distance rankings](https://en.wikipedia.org/wiki/Levenshtein_distance). I can then use the best matching address to look up its district.

I'm pretty happy with the resulting application, which looks up addresses at a rate of about 6 per second, much faster than manual entry. If the dataset grows larger, we could improve the lookup speed by parallelizing the API requests. Of the 6,049 addresses in the initial dataset, this tool was able to find districts for all but 280 of them, above a 95% hit rate.

Github: [coa-district-lookup](https://github.com/nateinaction/coa-district-lookup)
