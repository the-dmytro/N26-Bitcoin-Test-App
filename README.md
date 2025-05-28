Test app for iOS Engineer position to N26. The app functions are to fetch and display Bitcoin prices: current and historical, for 14 days back.

Testing of the app:
1. It's possible to run tests, written in BDD paradygm using Quick framework for the tests and its addition Nimble for using matchers.
   - To run the tests open the project in Xcode and wait for the frameworks to be fetched – they're added as Swift packages – then run the tests.
2. To test the app:
   - Fill API_KEY value in Keys.plist with a valid CoinGecko API key for Public API (https://docs.coingecko.com/v3.0.1/reference/introduction);
   - Select development team;
   - Run the app on device with iOS version 15 and newer;
   - Use UI should follow the specs and allow to see the prices, tap to retry on the section in case of a failure, tap on cells from historical prices list top see more details (price for given date in EUR, USD and GBP)

What the app misses:
- Nice human-readable texts for user-facing errors representation - they were left with raw localized descriptions;
- Sometimes test "when endpoint throws an error during request creation" fails with "Expected networkError but got invalidResponse" reason, sometimes it passes. Didn't manage to figure out root cause;
- The app works on the device fine, while in iOS simulator it fails to request the data: the requests end timed out. Might be my local issue – sometimes it worked well, more often not, with the same code;
- Endpoint could be made fully compatible with DI, this is what I began to do in the branch "improvements" but left incomplete in favor of completing more vital parts.

Overall I somewhat overengineered the app, trying to avoid oversimplification and better show my expertise
- it could be done without DI and uni-directional data flow, quite advanced for such simple app (see Container, Assembly, Repository and related code);
- the unit tests turned out to be quite extensive, they could be kept to bare minimum.

Disclaimer: the code was done with LLM-assisted code completion in very limited scope to speed up writing and editing the solutions I develop myself as an engineer.
Given that, I remain fully responsible for every decision, code organization and style, the completed task fully represents my own skills and exact ways to develop the apps.
