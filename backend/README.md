# Campus Canteen Backend

## Deployment Instructions

### 1. MongoDB Atlas Setup
1. Go to https://www.mongodb.com/cloud/atlas
2. Create free account
3. Create a cluster
4. Get connection string

### Environment Variables Required:
- `MONGODB_URI` - Your MongoDB Atlas connection string
- `JWT_SECRET` - Random secret key for JWT
- `EMAIL_USER` - Gmail address for sending OTPs
- `EMAIL_PASS` - Gmail app password
- `PORT` - Backend server port (example: `3000` for local development)

## Local Development
```bash
npm install
npm start
```
