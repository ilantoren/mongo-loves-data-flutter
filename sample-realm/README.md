#Sample Realm - HTTP inteface to Realm
<https://mongo-loves-data.medium.com/from-realm-to-flutter-15c8dd4037a7>

##The purpose of this application is to create a simple interface between the Flutter application and the realm environment.  
* byNeighborhood - restaurant data according to neighborhoood name and cuisines
* byCusine list of cuisines from the data where each cuisine appears at least n times and the results are sorted by most to least number of occurences

###Examples:
> curl "http://localhost:8080/byNeighborhood?name=Longwood&cuisines=["Pizza", "American", "Mexican", "Chinese"]"

> curl "http://localhost:8080/byCuisine?limit=10"

##.env
>NODE_ENV=development\
SERVER_PORT=8080\
REALM_ID='realm id'\
API_KEY='PUT YOUR GOOGLE MAPS API KEY HERE'\
HOST=0.0.0.0

