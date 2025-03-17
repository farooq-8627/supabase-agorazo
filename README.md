# Supabase Agorazo Backend

This repository contains the Supabase database configuration and migrations for the Agorazo e-commerce platform.

## Recent Changes

### Seller Information Update (2024-03-17)

The latest migration updates the seller information structure in the products table to include:
- name (replacing full_name)
- rating
- verified status

### How to Apply the Migration

1. Connect to your Supabase project
2. Run the migration:
   ```bash
   supabase db reset
   # or for just the latest migration
   supabase migration up
   ```

### New Seller Data Structure

```json
{
  "id": "string",
  "name": "string",
  "rating": number,
  "verified": boolean
}
```

Default values:
- name: "Tech Haven"
- rating: 4.9
- verified: true

## Features

- Automatic validation of seller data format
- Default values for missing fields
- Performance optimization with GIN index
- Backward compatibility with existing data