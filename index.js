var app = require('express')();
var http = require('http').Server(app);
var io = require('socket.io')(http);

var userList = [];
var keywordList = ["Sun", "Apple", "Chair"];
var hintList = ["Star", "Fruit", "Furniture"]

var roundCount = -1;
var rightUserCount = 0;

app.get('/', function(req, res){
  res.send('<h1>AppCoda - SocketChat Server</h1>');
});


http.listen(4000, function(){
  console.log('Listening on *:4000');
});

io.on('connection', function(clientSocket){
  console.log('a user connected');

  clientSocket.on('disconnect', function(){
    console.log('user disconnected');
  });

  clientSocket.on('drawLine', function(fromX,fromY,toX,toY) {
	io.emit('receiveDrawLine', fromX, fromY, toX, toY)
  });

  clientSocket.on('resetCanvas', function(){
  	console.log('Reseting Canvas')
  	io.emit('receiveResetCanvas')
  });

  clientSocket.on('sendGuess', function(guess,userID){
  	console.log('User ' + userID + ' guesses: '+ guess)
  	if (guess == keywordList[roundCount]) {
  		rightUserCount++;
  		
  		for (var i=0;i<userList.length;i++) { 
  				if (i==roundCount) {
  					userList[i]["score"] += 1
  				} else if (userList[i]["nickname"] == userID){
  					userList[i]["score"] += 2
  				}
  		}

  		if (rightUserCount<userList.length-1) {
  			io.emit('receiveSendGuess', guess, userID, 'right')
  			io.emit("receiveUsers", userList);
  		} else {
  			console.log("User " + userID + " trigged new round")
  			io.emit('receiveRevealAnswer')
  			io.emit("receiveUsers", userList);
  		}
  	} else {
  		io.emit('receiveSendGuess', guess, userID, 'wrong')
  	}

  });

  clientSocket.on('nextRound', function(){
  	startNewRound()
  });

  clientSocket.on("exitUser", function(clientNickname){
    for (var i=0; i<userList.length; i++) {
      if (userList[i]["id"] == clientSocket.id) {
        userList.splice(i, 1);
        break;
      }
    }
  });


  clientSocket.on("connectUser", function(clientNickname, avatar) {
      var message = "User " + clientNickname + " was connected.";
      console.log(message);

      var userInfo = {};
      var foundUser = false;
      for (var i=0; i<userList.length; i++) {
        if (userList[i]["nickname"] == clientNickname) {
          userList[i]["isConnected"] = true
          userList[i]["id"] = clientSocket.id;
          userList[i]["avatar"] = avatar
          userList[i]["score"] = 0
          userInfo = userList[i];
          foundUser = true;
          break;
        }
      }

      if (!foundUser) {
        userInfo["id"] = clientSocket.id;
        userInfo["nickname"] = clientNickname;
        userInfo["isConnected"] = true
        userInfo["avatar"] = avatar
        userInfo["score"] = 0
        userList.push(userInfo);
      }

      if (userList.length == 4) {
      	io.emit('receiveStartNewGame')
      	io.emit("receiveUsers", userList);
      	roundCount = -1
      	startNewRound()
      	console.log("New game started")
      }
  });

});

function restart() {
	io.emit('receiveRevealAnswer')
}

function startNewRound() {
	rightUserCount = 0
	roundCount = roundCount + 1
	console.log(roundCount)

  	if (roundCount >= keywordList.length) {
  		io.emit('receiveSendGuess', ' ', ' ', 'over')
  	} else {
  		io.emit('receiveStartNewRound', roundCount, keywordList[roundCount], hintList[roundCount], userList[roundCount]["nickname"])
  		console.log("User " + userList[roundCount]["nickname"] + " is drawing")
 	}
}
