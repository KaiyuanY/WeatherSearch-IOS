# WeatherSearch-IOS
An IOS app for weather search

* Used MVC design pattern to write the app.
* Implemented current location detection with CoreLocation. The weather condition of the current location is displayed on the home page on launch.
* The home page is implemented with UIScrollView and UIPageControl, which displays the user’s current location’s weather and saved (UserDefaults) locations’ weather.
* Implemented a search bar with UINavigationController to search weather conditions for specific places, and a UITableViewController with asynchronous HTTP requests to Google Places API to get autocomplete suggestions.
* Implemented UITabBarController to display weekly weather analysis charts with Hicharts.
* Used Alamofire for asynchronous HTTP requests from the backend, which is written in NodeJS and returns weather data from Tommorow.io API. Used SwiftyJSON for JSON data handling.
