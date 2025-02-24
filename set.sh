#!/bin/bash

echo "🚀 Setting up Printify Flutter Project Structure..."

# Define the folder structure
folders=(
    "lib/models"
    "lib/providers"
    "lib/services"
    "lib/utils"
    "lib/widgets"
    "lib/screens/auth"
    "lib/screens/student"
    "lib/screens/shop"
)

# Create folders
for folder in "${folders[@]}"; do
    mkdir -p $folder
    echo "📂 Created folder: $folder"
done

# Create files
touch lib/models/user_model.dart
touch lib/models/order_model.dart

touch lib/providers/auth_provider.dart
touch lib/providers/order_provider.dart
touch lib/providers/shop_provider.dart

touch lib/services/auth_service.dart
touch lib/services/order_service.dart
touch lib/services/payment_service.dart

touch lib/utils/constants.dart
touch lib/utils/themes.dart
touch lib/utils/helpers.dart

touch lib/widgets/primary_button.dart
touch lib/widgets/order_card.dart
touch lib/widgets/pdf_upload_widget.dart

touch lib/screens/auth/login_screen.dart
touch lib/screens/auth/register_screen.dart

touch lib/screens/student/home_screen.dart
touch lib/screens/student/new_order_screen.dart
touch lib/screens/student/order_tracking_screen.dart

touch lib/screens/shop/dashboard_screen.dart
touch lib/screens/shop/order_details_screen.dart

touch lib/router.dart

echo "🎉 Printify project structure created successfully!"
