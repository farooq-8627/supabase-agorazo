-- Update seller data in products table
BEGIN;

-- First, ensure the seller column is JSONB type
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 
        FROM information_schema.columns 
        WHERE table_name = 'products' 
        AND column_name = 'seller' 
        AND data_type = 'jsonb'
    ) THEN
        ALTER TABLE products 
        ALTER COLUMN seller TYPE jsonb USING seller::jsonb;
    END IF;
END $$;

-- Update existing seller data with new format
UPDATE products
SET seller = jsonb_build_object(
    'id', COALESCE(seller->>'id', ''),
    'name', 'Tech Haven',
    'rating', 4.9,
    'verified', true
)
WHERE seller IS NOT NULL;

-- Set default seller data for any NULL seller fields
UPDATE products
SET seller = jsonb_build_object(
    'id', '',
    'name', 'Tech Haven',
    'rating', 4.9,
    'verified', true
)
WHERE seller IS NULL;

-- Create or replace function to maintain seller data format
CREATE OR REPLACE FUNCTION maintain_seller_format()
RETURNS TRIGGER AS $$
BEGIN
    NEW.seller = jsonb_build_object(
        'id', COALESCE(NEW.seller->>'id', ''),
        'name', COALESCE(NEW.seller->>'name', 'Tech Haven'),
        'rating', COALESCE((NEW.seller->>'rating')::numeric, 4.9),
        'verified', COALESCE((NEW.seller->>'verified')::boolean, true)
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger to maintain seller format
DROP TRIGGER IF EXISTS ensure_seller_format ON products;
CREATE TRIGGER ensure_seller_format
    BEFORE INSERT OR UPDATE ON products
    FOR EACH ROW
    EXECUTE FUNCTION maintain_seller_format();

-- Verify the changes
SELECT 
    id,
    seller->>'name' as seller_name,
    seller->>'rating' as seller_rating,
    seller->>'verified' as seller_verified
FROM products
LIMIT 5;

COMMIT;