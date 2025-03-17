-- Update seller information in the products table
ALTER TABLE products 
DROP COLUMN seller,
ADD COLUMN seller jsonb DEFAULT jsonb_build_object(
  'id', '',
  'name', '',
  'rating', 0.0,
  'verified', false
);

-- Update existing seller data
UPDATE products
SET seller = jsonb_build_object(
  'id', seller->>'id',
  'name', COALESCE(seller->>'name', seller->>'full_name', 'Tech Haven'),
  'rating', 4.9,
  'verified', true
)
WHERE seller IS NOT NULL;

-- Add a trigger to ensure seller data format
CREATE OR REPLACE FUNCTION validate_seller_format()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.seller IS NULL THEN
    NEW.seller := jsonb_build_object(
      'id', '',
      'name', 'Tech Haven',
      'rating', 4.9,
      'verified', true
    );
  ELSE
    -- Ensure all required fields exist with default values if missing
    NEW.seller := jsonb_build_object(
      'id', COALESCE(NEW.seller->>'id', ''),
      'name', COALESCE(NEW.seller->>'name', 'Tech Haven'),
      'rating', COALESCE((NEW.seller->>'rating')::float, 4.9),
      'verified', COALESCE((NEW.seller->>'verified')::boolean, true)
    );
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS ensure_seller_format ON products;
CREATE TRIGGER ensure_seller_format
  BEFORE INSERT OR UPDATE ON products
  FOR EACH ROW
  EXECUTE FUNCTION validate_seller_format();

-- Create an index on seller data for better query performance
CREATE INDEX IF NOT EXISTS idx_products_seller ON products USING gin (seller);

-- Add a comment to the seller column
COMMENT ON COLUMN products.seller IS 'Seller information including name, rating, and verification status';