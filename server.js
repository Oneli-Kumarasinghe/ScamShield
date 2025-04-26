const express = require('express');
const bodyParser = require('body-parser');
const fs = require('fs');
const app = express();
const PORT = 3000;

app.use(bodyParser.json());

// Load users from file
const getUsers = () => {
  const data = fs.readFileSync('users.json');
  return JSON.parse(data);
};

const getReportedNumbers = () => {
  const data = fs.readFileSync('reportedNumbers.json');
  return JSON.parse(data);
};

// Save users to file
const saveUsers = (users) => {
  fs.writeFileSync('users.json', JSON.stringify(users, null, 2));
};

// Register
app.post('/register', (req, res) => {
  const { username, email, phone, location, password } = req.body;

  if (!username || !email || !phone || !location || !password) {
    return res.status(400).json({ message: 'All fields are required' });
  }

  const users = getUsers();

  if (users.find(user => user.username === username || user.email === email)) {
    return res.status(400).json({ message: 'Username or email already exists' });
  }

  const newUser = { username, email, phone, location, password };
  users.push(newUser);
  saveUsers(users);

  res.status(201).json({ message: 'User registered successfully', user: newUser });
});

// Login - Updated to return full user details
app.post('/login', (req, res) => {
  const { username, password } = req.body;
  const users = getUsers();

  const user = users.find(u => u.username === username && u.password === password);

  if (!user) {
    return res.status(401).json({ message: 'Invalid credentials' });
  }

  // Return the full user object
  res.status(200).json({ 
    message: 'Login successful', 
    user: user  // Now returning the complete user object
  });
});

// GET: Retrieve details of a reported number
app.get('/report/:number', (req, res) => {
  const number = req.params.number;
  const reports = getReportedNumbers();

  const report = reports.find(r => r.number === number);

  if (!report) {
    return res.status(404).json({ message: 'Number not found in reports' });
  }

  res.status(200).json(report);
});

// Add a new call report to a user
app.post('/reportCall', (req, res) => {
  const { username, number, reason, date } = req.body;

  if (!username || !number || !reason || !date) {
    return res.status(400).json({ message: 'All fields are required' });
  }

  const users = getUsers();
  const userIndex = users.findIndex(u => u.username === username);

  if (userIndex === -1) {
    return res.status(404).json({ message: 'User not found' });
  }

  const report = { number, reason, date };
  
  if (!users[userIndex].reportedCalls) {
    users[userIndex].reportedCalls = [];
  }

  users[userIndex].reportedCalls.push(report);
  saveUsers(users);

  res.status(200).json({ message: 'Call reported successfully', report });
});


app.listen(PORT, () => {
  console.log(`Server running on http://localhost:${PORT}`);
});
