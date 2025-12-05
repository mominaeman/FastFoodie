# Backend API for FastFoodie

This backend API connects Flutter web app to Google Cloud SQL database.

## Setup

1. Install Node.js (if not installed): https://nodejs.org/

2. Install dependencies:
```bash
cd backend
npm install
```

3. Update `.env` file with your database credentials (already configured)

4. Run the server:
```bash
npm start
```

Or for development with auto-restart:
```bash
npm run dev
```

## API Endpoints

Base URL: `http://localhost:3000/api`

### Health Check
- **GET** `/api/health` - Check if API and database are working

### Restaurants
- **GET** `/api/restaurants` - Get all active restaurants
- **GET** `/api/restaurants/search?q=pizza` - Search restaurants
- **GET** `/api/restaurants/:id/menu` - Get menu items for a restaurant

### Orders
- **POST** `/api/orders` - Create a new order
- **GET** `/api/users/:userId/orders` - Get user's orders
- **PATCH** `/api/orders/:id/status` - Update order status

## Example Requests

### Get Restaurants
```bash
curl http://localhost:3000/api/restaurants
```

### Create Order
```bash
curl -X POST http://localhost:3000/api/orders \
  -H "Content-Type: application/json" \
  -d '{
    "user_id": 1,
    "restaurant_id": 1,
    "total_amount": 25.50,
    "delivery_address": "123 Main St",
    "items": [
      {"menu_item_id": 1, "quantity": 2, "price": 12.75}
    ]
  }'
```

## Deploy to Google Cloud Run (Optional)

1. Create Dockerfile (see DEPLOYMENT.md)
2. Build and push to Google Container Registry
3. Deploy to Cloud Run
4. Update Flutter app to use Cloud Run URL

## Security Notes

- The `.env` file contains sensitive credentials
- Never commit `.env` to Git (already in .gitignore)
- For production, use Google Secret Manager
- Add authentication/authorization for production use
