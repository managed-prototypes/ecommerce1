use crate::context::Context;
use juniper::{EmptySubscription, FieldResult, RootNode};
use std::time::{SystemTime, UNIX_EPOCH};
impl juniper::Context for Context {}

type Schema = RootNode<'static, QueryRoot, MutationRoot, EmptySubscription<Context>>;

pub fn schema() -> Schema {
    Schema::new(QueryRoot, MutationRoot, EmptySubscription::<Context>::new())
}

pub struct QueryRoot;

#[juniper::graphql_object(Context = Context)]
impl QueryRoot {
    async fn products_v1(_context: &Context) -> FieldResult<Vec<Product>> {
        // let token_info = zitadel::introspect_token(context).await?;

        let product1 = Product {
            product_id: "1".to_string(),
            title: "Black Olives \"Manageed Protiopes\"".to_string(),
            image_url: "https://github.com/managed-prototypes/ecommerce1/blob/main/webapp/public/nocache/demo-images/1.jpg?raw=true".to_string(),
            price: UsdPrice("41.00".to_string()),
        };
        let product2 = Product {
            product_id: "2".to_string(),
            title: "Black Olives \"Managed Prototypes\"".to_string(),
            image_url: "https://github.com/managed-prototypes/ecommerce1/blob/main/webapp/public/nocache/demo-images/2.jpg?raw=true".to_string(),
            price: UsdPrice("42.00".to_string()),
        };
        let product3 = Product {
            product_id: "3".to_string(),
            title: "Assorted Olives \"Managed Prototyipes\"".to_string(),
            image_url: "https://github.com/managed-prototypes/ecommerce1/blob/main/webapp/public/nocache/demo-images/3.jpg?raw=true".to_string(),
            price: UsdPrice("43.00".to_string()),
        };
        let product4 = Product {
            product_id: "4".to_string(),
            title: "Black Olves \"Managed Proptoyiptes\"".to_string(),
            image_url: "https://github.com/managed-prototypes/ecommerce1/blob/main/webapp/public/nocache/demo-images/4.jpg?raw=true".to_string(),
            price: UsdPrice("44.00".to_string()),
        };
        let available_products = vec![product1, product2, product3, product4];

        Ok(available_products)
    }

    async fn cart_v1(_context: &Context) -> FieldResult<Cart> {
        // let token_info = zitadel::introspect_token(context).await?;

        let cart = Cart {
            items: vec![
                CartItem {
                    product: Product {
                        product_id: "1".to_string(),
                        title: "Black Olives \"Manageed Protiopes\"".to_string(),
                        image_url: "https://github.com/managed-prototypes/ecommerce1/blob/main/webapp/public/nocache/demo-images/1.jpg?raw=true".to_string(),
                        price: UsdPrice("41.00".to_string()),
                    },
                    quantity: 2,
                    item_total: UsdAmount("84.00".to_string()),
                },
                CartItem {
                    product: Product {
                        product_id: "2".to_string(),
                        title: "Black Olives \"Managed Prototypes\"".to_string(),
                        image_url: "https://github.com/managed-prototypes/ecommerce1/blob/main/webapp/public/nocache/demo-images/2.jpg?raw=true".to_string(),
                        price: UsdPrice("42.00".to_string()),
                    },
                    quantity: 1,
                    item_total: UsdAmount("43.00".to_string()),
                },
            ],
            total: UsdAmount("127.00".to_string()),
        };
        Ok(cart)
    }

    async fn pickup_points_v1(_context: &Context) -> FieldResult<Vec<PickupPoint>> {
        // let token_info = zitadel::introspect_token(context).await?;

        let pickup_point1 = PickupPoint {
            pickup_point_id: "1".to_string(),
            title: "Pick-up point 1".to_string(),
        };
        let pickup_point2 = PickupPoint {
            pickup_point_id: "2".to_string(),
            title: "Pick-up point 2".to_string(),
        };
        let available_pickup_points = vec![pickup_point1, pickup_point2];

        Ok(available_pickup_points)
    }

    async fn my_orders_v1(_context: &Context) -> FieldResult<Vec<Order>> {
        // let token_info = zitadel::introspect_token(context).await?;
        // let user_id = UserId(token_info.sub.clone());

        let order1 = Order {
            order_id: "1".to_string(),
            created_at: Timestamp::from( SystemTime::now().duration_since(UNIX_EPOCH)?.as_millis() as u64 ),
            items: vec![
                OrderItem {
                    product: Product {
                        product_id: "1".to_string(),
                        title: "Black Olives \"Manageed Protiopes\"".to_string(),
                        image_url: "https://github.com/managed-prototypes/ecommerce1/blob/main/webapp/public/nocache/demo-images/1.jpg?raw=true".to_string(),
                        price: UsdPrice("41.00".to_string()),
                    },
                    quantity: 2,
                    item_total: UsdAmount("84.00".to_string()),
                },
                OrderItem {
                    product: Product {
                        product_id: "2".to_string(),
                        title: "Black Olives \"Managed Prototypes\"".to_string(),
                        image_url: "https://github.com/managed-prototypes/ecommerce1/blob/main/webapp/public/nocache/demo-images/2.jpg?raw=true".to_string(),
                        price: UsdPrice("42.00".to_string()),
                    },
                    quantity: 1,
                    item_total: UsdAmount("43.00".to_string()),
                },
            ],
            status: OrderStatus::Delivered,
            total: UsdAmount("127.00".to_string()),
            shipping_option: ShippingOption::Delivery(ShippingOptionDelivery {
                address: "123 Main St, Springfield, IL 62701".to_string(),
            }),
        };

        let order2 = Order {
            created_at: Timestamp::from( SystemTime::now().duration_since(UNIX_EPOCH)?.as_millis() as u64 ),
            order_id: "2".to_string(),
            items: vec![OrderItem {
                product: Product {
                    product_id: "1".to_string(),
                    title: "Black Olives \"Manageed Protiopes\"".to_string(),
                    image_url: "https://github.com/managed-prototypes/ecommerce1/blob/main/webapp/public/nocache/demo-images/1.jpg?raw=true".to_string(),
                    price: UsdPrice("41.00".to_string()),
                },
                quantity: 1,
                item_total: UsdAmount("42.00".to_string()),
            }],
            status: OrderStatus::Pending,
            total: UsdAmount("42.00".to_string()),
            shipping_option: ShippingOption::Pickup(PickupPoint {
                pickup_point_id: "1".to_string(),
                title: "Pick-up point 1".to_string(),
            }),
        };

        let my_orders = vec![order1, order2];
        Ok(my_orders)
    }

    async fn admin_products_v1(_context: &Context) -> FieldResult<Vec<Product>> {
        // let token_info = zitadel::introspect_token(context).await?;
        // require_role(&token_info, &ADMINISTRATOR_ROLE.to_string())?;

        let product1 = Product {
            product_id: "1".to_string(),
            title: "Black Olives \"Manageed Protiopes\"".to_string(),
            image_url: "https://github.com/managed-prototypes/ecommerce1/blob/main/webapp/public/nocache/demo-images/1.jpg?raw=true".to_string(),
            price: UsdPrice("41.00".to_string()),
        };
        let product2 = Product {
            product_id: "2".to_string(),
            title: "Black Olives \"Managed Prototypes\"".to_string(),
            image_url: "https://github.com/managed-prototypes/ecommerce1/blob/main/webapp/public/nocache/demo-images/2.jpg?raw=true".to_string(),
            price: UsdPrice("42.00".to_string()),
        };
        let product3 = Product {
            product_id: "3".to_string(),
            title: "Assorted Olives \"Managed Prototyipes\"".to_string(),
            image_url: "https://github.com/managed-prototypes/ecommerce1/blob/main/webapp/public/nocache/demo-images/3.jpg?raw=true".to_string(),
            price: UsdPrice("43.00".to_string()),
        };
        let product4 = Product {
            product_id: "4".to_string(),
            title: "Black Olves \"Managed Proptoyiptes\"".to_string(),
            image_url: "https://github.com/managed-prototypes/ecommerce1/blob/main/webapp/public/nocache/demo-images/4.jpg?raw=true".to_string(),
            price: UsdPrice("44.00".to_string()),
        };
        let available_products = vec![product1, product2, product3, product4];

        Ok(available_products)
    }

    async fn admin_product_v1(_context: &Context, product_id: String) -> FieldResult<Product> {
        // let token_info = zitadel::introspect_token(context).await?;
        // require_role(&token_info, &ADMINISTRATOR_ROLE.to_string())?;

        let product1 = Product {
            product_id: product_id,
            title: "Black Olives \"Manageed Protiopes\"".to_string(),
            image_url: "https://github.com/managed-prototypes/ecommerce1/blob/main/webapp/public/nocache/demo-images/1.jpg?raw=true".to_string(),
            price: UsdPrice("41.00".to_string()),
        };
        Ok(product1)
    }

    async fn admin_customer_orders_v1(_context: &Context) -> FieldResult<Vec<CustomerOrder>> {
        // let token_info = zitadel::introspect_token(context).await?;
        // require_role(&token_info, &ADMINISTRATOR_ROLE.to_string())?;

        let customer1 = Customer {
            user_id: "1".to_string(),
            display_name: "Charles d'Artagnan".to_string(),
        };
        let customer2 = Customer {
            user_id: "2".to_string(),
            display_name: "Kim Kardashian".to_string(),
        };

        let order1 = CustomerOrder {
            order_id: "1".to_string(),
            created_at: Timestamp::from( SystemTime::now().duration_since(UNIX_EPOCH)?.as_millis() as u64 ),
            customer: customer1.clone(),
            items: vec![
                OrderItem {
                    product: Product {
                        product_id: "1".to_string(),
                        title: "Black Olives \"Manageed Protiopes\"".to_string(),
                        image_url: "https://github.com/managed-prototypes/ecommerce1/blob/main/webapp/public/nocache/demo-images/1.jpg?raw=true".to_string(),
                        price: UsdPrice("41.00".to_string()),
                    },
                    quantity: 2,
                    item_total: UsdAmount("84.00".to_string()),
                },
                OrderItem {
                    product: Product {
                        product_id: "2".to_string(),
                        title: "Black Olives \"Managed Prototypes\"".to_string(),
                        image_url: "https://github.com/managed-prototypes/ecommerce1/blob/main/webapp/public/nocache/demo-images/2.jpg?raw=true".to_string(),
                        price: UsdPrice("42.00".to_string()),
                    },
                    quantity: 1,
                    item_total: UsdAmount("43.00".to_string()),
                },
            ],
            status: OrderStatus::Delivered,
            total: UsdAmount("127.00".to_string()),
            shipping_option: ShippingOption::Delivery(ShippingOptionDelivery {
                address: "123 Main St, Springfield, IL 62701".to_string(),
            }),
        };

        let order2 = CustomerOrder {
            order_id: "2".to_string(),
            created_at: Timestamp::from( SystemTime::now().duration_since(UNIX_EPOCH)?.as_millis() as u64 ),
            customer: customer2.clone(),
            items: vec![OrderItem {
                product: Product {
                    product_id: "1".to_string(),
                    title: "Black Olives \"Manageed Protiopes\"".to_string(),
                    image_url: "https://github.com/managed-prototypes/ecommerce1/blob/main/webapp/public/nocache/demo-images/1.jpg?raw=true".to_string(),
                    price: UsdPrice("41.00".to_string()),
                },
                quantity: 1,
                item_total: UsdAmount("42.00".to_string()),
            }],
            status: OrderStatus::Pending,
            total: UsdAmount("42.00".to_string()),
            shipping_option: ShippingOption::Pickup(PickupPoint {
                pickup_point_id: "1".to_string(),
                title: "Pick-up point 1".to_string(),
            }),
        };

        let customer_orders = vec![order1, order2];
        Ok(customer_orders)
    }
}

pub struct MutationRoot;

#[juniper::graphql_object(Context = Context)]
impl MutationRoot {
    async fn set_cart_product_quantity_v1(
        _context: &Context,
        _product_id: ProductInput,
        _quantity: i32,
    ) -> FieldResult<Unit> {
        // let token_info = zitadel::introspect_token(context).await?;
        // require_role(&token_info, &ADMINISTRATOR_ROLE.to_string())?;

        Ok(Unit::from(()))
        // Err("Not implemented".into())
    }

    async fn admin_product_create_v1(
        _context: &Context,
        _product_input: ProductInput,
    ) -> FieldResult<Unit> {
        // let token_info = zitadel::introspect_token(context).await?;
        // require_role(&token_info, &ADMINISTRATOR_ROLE.to_string())?;

        Ok(Unit::from(()))
        // Err("Not implemented".into())
    }

    async fn admin_product_update_v1(
        _context: &Context,
        _product_id: String,
        _product_input: ProductInput,
    ) -> FieldResult<Unit> {
        // let token_info = zitadel::introspect_token(context).await?;
        // require_role(&token_info, &ADMINISTRATOR_ROLE.to_string())?;

        Ok(Unit::from(()))
    }

    async fn admin_product_delete_v1(_context: &Context, _product_id: String) -> FieldResult<Unit> {
        // let token_info = zitadel::introspect_token(context).await?;
        // require_role(&token_info, &ADMINISTRATOR_ROLE.to_string())?;

        Ok(Unit::from(()))
    }
}

#[derive(juniper::GraphQLScalarValue)]
#[graphql(transparent, description = "UNIX timestamp, millis, as a string")]
pub struct Timestamp(String);

impl From<u128> for Timestamp {
    fn from(millis: u128) -> Self {
        Timestamp(millis.to_string())
    }
}

impl From<u64> for Timestamp {
    fn from(millis: u64) -> Self {
        Timestamp(millis.to_string())
    }
}

#[derive(juniper::GraphQLScalarValue)]
#[graphql(transparent, description = "Unit, an empty string")]
pub struct Unit(String);

impl From<()> for Unit {
    fn from(_unit: ()) -> Self {
        Unit("".to_string())
    }
}

// ===================== shop
#[derive(juniper::GraphQLScalarValue)]
#[graphql(
    transparent,
    description = "USD price, as a string containing decimal value, non-negative, 2 decimal places. e.g. 12.99"
)]
pub struct UsdPrice(String);

#[derive(juniper::GraphQLScalarValue)]
#[graphql(
    transparent,
    description = "USD amount, as a string containing decimal value, non-negative, 2 decimal places. e.g. 12.99"
)]
pub struct UsdAmount(String);

#[derive(juniper::GraphQLInputObject)]
struct ProductInput {
    title: String,
    image_url: String,
    price: UsdPrice,
}

#[derive(juniper::GraphQLObject)]
#[graphql(description = "A product to be displayed in the store")]
struct Product {
    product_id: String,
    title: String,
    image_url: String,
    // For Shop and for Cart it's the current price,
    // for Order it's the price at the moment of the order
    price: UsdPrice,
}

#[derive(juniper::GraphQLObject)]
#[graphql(description = "An item to be displayed in the cart")]
struct CartItem {
    product: Product,
    quantity: i32,
    item_total: UsdAmount,
}

#[derive(juniper::GraphQLObject)]
#[graphql(description = "Cart contents")]
struct Cart {
    items: Vec<CartItem>,
    total: UsdAmount,
}

#[derive(juniper::GraphQLObject)]
#[graphql(description = "Pick-up point for the order")]
struct PickupPoint {
    pickup_point_id: String,
    title: String,
}

#[derive(juniper::GraphQLEnum)]
#[graphql(description = "Order status")]
enum OrderStatus {
    Pending,
    Shipped,
    Delivered,
    Cancelled,
}

#[derive(juniper::GraphQLObject)]
#[graphql(description = "Order item")]
struct OrderItem {
    product: Product,
    quantity: i32,
    item_total: UsdAmount,
}

#[derive(juniper::GraphQLObject)]
#[graphql(description = "Order")]
struct Order {
    order_id: String,
    created_at: Timestamp,
    items: Vec<OrderItem>,
    status: OrderStatus,
    total: UsdAmount,
    shipping_option: ShippingOption,
}

#[derive(juniper::GraphQLUnion)]
#[graphql(description = "Shipping option")]
enum ShippingOption {
    Pickup(PickupPoint),
    Delivery(ShippingOptionDelivery),
}

#[derive(juniper::GraphQLObject)]
#[graphql(description = "Shipping option: delivery")]
struct ShippingOptionDelivery {
    address: String,
}

#[derive(Clone, juniper::GraphQLObject)]
#[graphql(description = "Customer")]
struct Customer {
    user_id: String,
    display_name: String,
}

#[derive(juniper::GraphQLObject)]
#[graphql(description = "Admin: Customer's order")]
struct CustomerOrder {
    order_id: String,
    created_at: Timestamp,
    customer: Customer,
    items: Vec<OrderItem>,
    status: OrderStatus,
    total: UsdAmount,
    shipping_option: ShippingOption,
}
