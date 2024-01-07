![Logo-transparent](https://user-images.githubusercontent.com/49759922/133775221-ee6601a0-071d-4f21-83b3-19f4b7c7c58e.png)

**Welcome to the RociFi NFCS Oracle repository!** :milky_way:

The score oracle handles fetching of credit scores from off-chain and delivering said scores to the caller contracts.

The code currently includes a caller contract (this is a contract that calls the oracle to fetch score for a tokenId) and an oracle contract (the contract which is the bridge between the Ethereum protocol and the outside world), along with their respective interfaces with the relevant functions exposed. 

Score Fetching Process Flow:

1. Caller asks oracle for score of a given tokenId.

2. Oracle generates a new request Id for this request and returns it to the caller. This is because oracle cannot return score instantaneously.

3. Oracle emits a new event with the caller address, tokenId and the request Id.

4. This event is being listened to by the off-chain service running in the cloud. Once it is detected, the service calls the relevant API, passing it the token Id, which then returns the score for the given tokenId.

5. The off-chain service then calls a function in the oracle to set the score for the given token Id, this function in turn calls a callback function inside the caller contract along with the score, the tokenId and the requestId.

6. Finally, the callback function in the caller contract sets the score for the given tokenId in the tokenId to score mapping.

⚠️The smart contracts use openzeppelin Ownable contract which has not been uploaded. The full project directory will be uploaded soon. However, The present code is enough to go through and assess its functionality.
