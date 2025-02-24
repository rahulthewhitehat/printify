#!/bin/bash

# Define directories
dirs=(
    "core/widgets"
    "models"
    "providers"
    "services"
    "screens/auth"
    "screens/home"
    "screens/orders"
    "screens/shop_owner"
    "utils"
)

# Create directories
for dir in "${dirs[@]}"; do
    mkdir -p "$dir"
done

# Define files
files=(
    "main.dart"
    "app.dart"
    "core/theme.dart"
    "core/constants.dart"
    "core/widgets/custom_button.dart"
    "core/widgets/custom_icon.dart"
    "core/widgets/custom_textfield.dart"
    "models/order_model.dart"
    "models/user_model.dart"
    "models/print_settings.dart"
    "providers/auth_provider.dart"
    "providers/order_provider.dart"
    "providers/print_provider.dart"
    "providers/payment_provider.dart"
    "services/firestore_service.dart"
    "services/auth_service.dart"
    "services/payment_service.dart"
    "services/storage_service.dart"
    "screens/auth/login_screen.dart"
    "screens/auth/register_screen.dart"
    "screens/home/home_screen.dart"
    "screens/orders/new_order_screen.dart"
    "screens/orders/order_details.dart"
    "screens/orders/order_tracking.dart"
    "screens/shop_owner/dashboard_screen.dart"
    "screens/shop_owner/orders_list.dart"
    "utils/helpers.dart"
    "utils/formatters.dart"
    "utils/validators.dart"
)

# Create empty files
for file in "${files[@]}"; do
    touch "$file"
done

echo "✅ Project structure created successfully!"
