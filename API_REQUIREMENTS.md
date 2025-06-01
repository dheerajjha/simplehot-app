# SimpleHot API Requirements

This document outlines all the API endpoints required for the SimpleHot mobile application - a Twitter-like platform for Indian stock predictions.

## Overview

SimpleHot is a social platform where users can:
- Make stock predictions with target prices and dates
- Follow other users and see their predictions
- Like and comment on predictions
- View real-time stock data
- Get automatically verified predictions when target dates are reached

## Base URL
- **Gateway API**: `http://20.193.143.179:5050`
- All endpoints should be prefixed with `/api/` unless specified otherwise

## Authentication

### Headers
All authenticated endpoints require:
```
x-auth-token: <JWT_TOKEN>
```

### Endpoints

#### 1. Register User
- **Method**: `POST`
- **Endpoint**: `/api/auth/register`
- **Body**:
```json
{
  "email": "user@example.com",
  "password": "password123"
}
```
- **Response** (201):
```json
{
  "token": "jwt_token_here",
  "user": {
    "id": "user_id",
    "email": "user@example.com",
    "name": null,
    "username": null,
    "bio": null,
    "profileImageUrl": null,
    "createdAt": "2024-01-01T00:00:00Z",
    "following": [],
    "followers": []
  }
}
```

#### 2. Login User
- **Method**: `POST`
- **Endpoint**: `/api/auth/login`
- **Body**:
```json
{
  "email": "user@example.com",
  "password": "password123"
}
```
- **Response** (200):
```json
{
  "token": "jwt_token_here",
  "user": {
    "id": "user_id",
    "email": "user@example.com",
    "name": "User Name",
    "username": "username",
    "bio": "User bio",
    "profileImageUrl": "https://example.com/image.jpg",
    "createdAt": "2024-01-01T00:00:00Z",
    "following": ["user_id_1", "user_id_2"],
    "followers": ["user_id_3", "user_id_4"]
  }
}
```

#### 3. Verify Token
- **Method**: `GET`
- **Endpoint**: `/api/auth/verify`
- **Headers**: `x-auth-token: <token>`
- **Response** (200):
```json
{
  "valid": true,
  "userId": "user_id"
}
```

## User Management

#### 4. Get Current User Profile
- **Method**: `GET`
- **Endpoint**: `/api/users/profile`
- **Headers**: `x-auth-token: <token>`
- **Response** (200):
```json
{
  "id": "user_id",
  "email": "user@example.com",
  "name": "User Name",
  "username": "username",
  "bio": "User bio",
  "profileImageUrl": "https://example.com/image.jpg",
  "createdAt": "2024-01-01T00:00:00Z",
  "following": ["user_id_1", "user_id_2"],
  "followers": ["user_id_3", "user_id_4"]
}
```

#### 5. Update User Profile
- **Method**: `PUT`
- **Endpoint**: `/api/users/profile`
- **Headers**: `x-auth-token: <token>`
- **Body**:
```json
{
  "name": "Updated Name",
  "username": "new_username",
  "bio": "Updated bio",
  "profileImageUrl": "https://example.com/new_image.jpg"
}
```
- **Response** (200):
```json
{
  "id": "user_id",
  "email": "user@example.com",
  "name": "Updated Name",
  "username": "new_username",
  "bio": "Updated bio",
  "profileImageUrl": "https://example.com/new_image.jpg",
  "createdAt": "2024-01-01T00:00:00Z",
  "following": ["user_id_1", "user_id_2"],
  "followers": ["user_id_3", "user_id_4"]
}
```

#### 6. Get User by ID
- **Method**: `GET`
- **Endpoint**: `/api/users/:id`
- **Headers**: `x-auth-token: <token>`
- **Response** (200): Same as user profile structure

#### 7. Follow User
- **Method**: `POST`
- **Endpoint**: `/api/users/:id/follow`
- **Headers**: `x-auth-token: <token>`
- **Response** (200):
```json
{
  "success": true,
  "message": "User followed successfully"
}
```

#### 8. Unfollow User
- **Method**: `DELETE`
- **Endpoint**: `/api/users/:id/follow`
- **Headers**: `x-auth-token: <token>`
- **Response** (200):
```json
{
  "success": true,
  "message": "User unfollowed successfully"
}
```

#### 9. Get User Followers
- **Method**: `GET`
- **Endpoint**: `/api/users/:id/followers`
- **Headers**: `x-auth-token: <token>`
- **Response** (200):
```json
[
  {
    "id": "follower_id",
    "email": "follower@example.com",
    "name": "Follower Name",
    "username": "follower_username",
    "profileImageUrl": "https://example.com/follower.jpg",
    "createdAt": "2024-01-01T00:00:00Z"
  }
]
```

#### 10. Get User Following
- **Method**: `GET`
- **Endpoint**: `/api/users/:id/following`
- **Headers**: `x-auth-token: <token>`
- **Response** (200): Same structure as followers

## Posts/Predictions

#### 11. Create Post
- **Method**: `POST`
- **Endpoint**: `/api/posts`
- **Headers**: `x-auth-token: <token>`
- **Body**:
```json
{
  "content": "Post content here",
  "imageUrl": "https://example.com/image.jpg"
}
```
- **Response** (201):
```json
{
  "id": "post_id",
  "userId": "user_id",
  "content": "Post content here",
  "imageUrl": "https://example.com/image.jpg",
  "createdAt": "2024-01-01T00:00:00Z",
  "likes": [],
  "commentCount": 0
}
```

#### 12. Get Post by ID
- **Method**: `GET`
- **Endpoint**: `/api/posts/:id`
- **Headers**: `x-auth-token: <token>`
- **Response** (200): Same as create post response

#### 13. Get Posts by User
- **Method**: `GET`
- **Endpoint**: `/api/posts/user/:userId`
- **Headers**: `x-auth-token: <token>`
- **Query Parameters**: `?page=1&limit=10`
- **Response** (200):
```json
[
  {
    "id": "post_id",
    "userId": "user_id",
    "content": "Post content",
    "imageUrl": "https://example.com/image.jpg",
    "createdAt": "2024-01-01T00:00:00Z",
    "likes": ["user_id_1", "user_id_2"],
    "commentCount": 5
  }
]
```

#### 14. Like Post
- **Method**: `POST`
- **Endpoint**: `/api/posts/:id/like`
- **Headers**: `x-auth-token: <token>`
- **Response** (200):
```json
{
  "success": true,
  "message": "Post liked successfully"
}
```

#### 15. Unlike Post
- **Method**: `DELETE`
- **Endpoint**: `/api/posts/:id/like`
- **Headers**: `x-auth-token: <token>`
- **Response** (200):
```json
{
  "success": true,
  "message": "Post unliked successfully"
}
```

#### 16. Get Post Likes
- **Method**: `GET`
- **Endpoint**: `/api/posts/:id/likes`
- **Headers**: `x-auth-token: <token>`
- **Response** (200):
```json
["user_id_1", "user_id_2", "user_id_3"]
```

#### 17. Add Comment to Post
- **Method**: `POST`
- **Endpoint**: `/api/posts/:id/comments`
- **Headers**: `x-auth-token: <token>`
- **Body**:
```json
{
  "content": "This is a comment"
}
```
- **Response** (201):
```json
{
  "id": "comment_id",
  "postId": "post_id",
  "userId": "user_id",
  "content": "This is a comment",
  "createdAt": "2024-01-01T00:00:00Z"
}
```

#### 18. Get Post Comments
- **Method**: `GET`
- **Endpoint**: `/api/posts/:id/comments`
- **Headers**: `x-auth-token: <token>`
- **Response** (200):
```json
[
  {
    "id": "comment_id",
    "postId": "post_id",
    "userId": "user_id",
    "content": "This is a comment",
    "createdAt": "2024-01-01T00:00:00Z",
    "user": {
      "name": "User Name",
      "username": "username",
      "profileImageUrl": "https://example.com/user.jpg"
    }
  }
]
```

## Stock Data (Required for Stock Predictions Feature)

#### 19. Get Trending Stocks
- **Method**: `GET`
- **Endpoint**: `/api/stocks/trending`
- **Headers**: `x-auth-token: <token>`
- **Response** (200):
```json
[
  {
    "symbol": "RELIANCE",
    "name": "Reliance Industries",
    "currentPrice": 2500.75,
    "change": 25.50,
    "changePercent": 1.03,
    "volume": 3500000,
    "marketCap": 1500000000000,
    "lastUpdated": "2024-01-01T00:00:00Z"
  }
]
```

#### 20. Get Stock Details
- **Method**: `GET`
- **Endpoint**: `/api/stocks/:symbol`
- **Headers**: `x-auth-token: <token>`
- **Response** (200):
```json
{
  "symbol": "RELIANCE",
  "name": "Reliance Industries",
  "currentPrice": 2500.75,
  "change": 25.50,
  "changePercent": 1.03,
  "volume": 3500000,
  "marketCap": 1500000000000,
  "dayHigh": 2520.00,
  "dayLow": 2480.00,
  "yearHigh": 2800.00,
  "yearLow": 2000.00,
  "lastUpdated": "2024-01-01T00:00:00Z"
}
```

#### 21. Search Stocks
- **Method**: `GET`
- **Endpoint**: `/api/stocks/search`
- **Headers**: `x-auth-token: <token>`
- **Query Parameters**: `?q=reliance`
- **Response** (200): Array of stock objects (same structure as trending stocks)

#### 22. Get Stock Historical Data
- **Method**: `GET`
- **Endpoint**: `/api/stocks/:symbol/history`
- **Headers**: `x-auth-token: <token>`
- **Query Parameters**: `?period=1M` (1D, 1W, 1M, 3M, 6M, 1Y)
- **Response** (200):
```json
[
  {
    "date": "2024-01-01",
    "open": 2480.00,
    "high": 2520.00,
    "low": 2470.00,
    "close": 2500.75,
    "volume": 3500000
  }
]
```

## Stock Predictions (Core Feature)

#### 23. Create Stock Prediction
- **Method**: `POST`
- **Endpoint**: `/api/predictions`
- **Headers**: `x-auth-token: <token>`
- **Body**:
```json
{
  "stockSymbol": "RELIANCE",
  "targetPrice": 2600.00,
  "targetDate": "2024-02-01T00:00:00Z",
  "direction": "up",
  "description": "Expecting growth due to new refinery project",
  "currentPrice": 2500.75
}
```
- **Response** (201):
```json
{
  "id": "prediction_id",
  "stockSymbol": "RELIANCE",
  "stockName": "Reliance Industries",
  "userId": "user_id",
  "targetPrice": 2600.00,
  "currentPrice": 2500.75,
  "targetDate": "2024-02-01T00:00:00Z",
  "direction": "up",
  "description": "Expecting growth due to new refinery project",
  "status": "pending",
  "createdAt": "2024-01-01T00:00:00Z",
  "likes": [],
  "commentCount": 0,
  "percentageDifference": 3.97
}
```

#### 24. Get Trending Predictions
- **Method**: `GET`
- **Endpoint**: `/api/predictions/trending`
- **Headers**: `x-auth-token: <token>`
- **Query Parameters**: `?page=1&limit=10`
- **Response** (200):
```json
[
  {
    "id": "prediction_id",
    "stockSymbol": "RELIANCE",
    "stockName": "Reliance Industries",
    "userId": "user_id",
    "user": {
      "name": "User Name",
      "username": "username",
      "profileImageUrl": "https://example.com/user.jpg"
    },
    "targetPrice": 2600.00,
    "currentPrice": 2500.75,
    "targetDate": "2024-02-01T00:00:00Z",
    "direction": "up",
    "description": "Expecting growth due to new refinery project",
    "status": "pending",
    "createdAt": "2024-01-01T00:00:00Z",
    "likes": ["user_id_1", "user_id_2"],
    "commentCount": 5,
    "percentageDifference": 3.97
  }
]
```

#### 25. Get Predictions for Stock
- **Method**: `GET`
- **Endpoint**: `/api/predictions/stock/:symbol`
- **Headers**: `x-auth-token: <token>`
- **Query Parameters**: `?page=1&limit=10`
- **Response** (200): Array of predictions (same structure as trending)

#### 26. Get User's Predictions
- **Method**: `GET`
- **Endpoint**: `/api/predictions/user/:userId`
- **Headers**: `x-auth-token: <token>`
- **Query Parameters**: `?page=1&limit=10`
- **Response** (200): Array of predictions (same structure as trending)

#### 27. Like Prediction
- **Method**: `POST`
- **Endpoint**: `/api/predictions/:id/like`
- **Headers**: `x-auth-token: <token>`
- **Response** (200):
```json
{
  "success": true,
  "message": "Prediction liked successfully"
}
```

#### 28. Unlike Prediction
- **Method**: `DELETE`
- **Endpoint**: `/api/predictions/:id/like`
- **Headers**: `x-auth-token: <token>`
- **Response** (200):
```json
{
  "success": true,
  "message": "Prediction unliked successfully"
}
```

#### 29. Comment on Prediction
- **Method**: `POST`
- **Endpoint**: `/api/predictions/:id/comments`
- **Headers**: `x-auth-token: <token>`
- **Body**:
```json
{
  "content": "Great analysis!"
}
```
- **Response** (201):
```json
{
  "id": "comment_id",
  "predictionId": "prediction_id",
  "userId": "user_id",
  "content": "Great analysis!",
  "createdAt": "2024-01-01T00:00:00Z"
}
```

#### 30. Get Prediction Comments
- **Method**: `GET`
- **Endpoint**: `/api/predictions/:id/comments`
- **Headers**: `x-auth-token: <token>`
- **Response** (200):
```json
[
  {
    "id": "comment_id",
    "predictionId": "prediction_id",
    "userId": "user_id",
    "content": "Great analysis!",
    "createdAt": "2024-01-01T00:00:00Z",
    "user": {
      "name": "User Name",
      "username": "username",
      "profileImageUrl": "https://example.com/user.jpg"
    }
  }
]
```

## News Feed (Optional Feature)

#### 31. Get Stock News
- **Method**: `GET`
- **Endpoint**: `/api/news/stocks`
- **Headers**: `x-auth-token: <token>`
- **Query Parameters**: `?symbol=RELIANCE&page=1&limit=10`
- **Response** (200):
```json
[
  {
    "id": "news_id",
    "title": "Reliance Industries announces new project",
    "summary": "Company plans major expansion...",
    "url": "https://example.com/news/article",
    "source": "Economic Times",
    "publishedAt": "2024-01-01T00:00:00Z",
    "imageUrl": "https://example.com/news/image.jpg",
    "relatedStocks": ["RELIANCE"]
  }
]
```

## Health Check

#### 32. Health Check
- **Method**: `GET`
- **Endpoint**: `/health`
- **Response** (200):
```json
{
  "status": "healthy",
  "timestamp": "2024-01-01T00:00:00Z",
  "services": {
    "database": "connected",
    "redis": "connected",
    "external_apis": "connected"
  }
}
```

## Error Responses

All endpoints should return appropriate HTTP status codes and error messages:

### 400 Bad Request
```json
{
  "error": "Invalid request data",
  "details": "Email is required"
}
```

### 401 Unauthorized
```json
{
  "error": "Unauthorized",
  "details": "Invalid or expired token"
}
```

### 404 Not Found
```json
{
  "error": "Resource not found",
  "details": "User with ID 'user_id' not found"
}
```

### 500 Internal Server Error
```json
{
  "error": "Internal server error",
  "details": "Database connection failed"
}
```

## Additional Requirements

### 1. Real-time Features (WebSocket/Server-Sent Events)
- Real-time stock price updates
- Live prediction status updates
- Real-time notifications for likes, comments, follows

### 2. Background Jobs
- **Prediction Verification**: Automatically check predictions when target dates are reached
- **Stock Data Updates**: Regular updates of stock prices and market data
- **Notification System**: Send push notifications for important events

### 3. Data Sources Integration
- **Stock Data**: Integration with Indian stock market APIs (NSE, BSE)
- **News Data**: Integration with financial news APIs
- **Market Data**: Real-time and historical stock data

### 4. Performance Requirements
- Response time < 200ms for most endpoints
- Support for 10,000+ concurrent users
- Efficient pagination for large datasets
- Caching for frequently accessed data

### 5. Security Requirements
- JWT token authentication
- Rate limiting on all endpoints
- Input validation and sanitization
- HTTPS only in production
- CORS configuration for mobile app

This API specification provides the complete backend requirements for the SimpleHot application. The backend developer can use this as a comprehensive guide to implement all necessary endpoints and features. 