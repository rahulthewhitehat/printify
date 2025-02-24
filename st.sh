#!/bin/bash

mkdir -p lib/{core/widgets,models,providers,services,screens/{auth,home,orders,shop_owner},utils}

# Create main files
touch lib/{main.dart,app.dart}

# Core files
touch lib/core/{theme.dart,constants.dart}
touch lib/core/widgets/{custom_button.dart,custom_icon.dart,custom_textfield.dart}

# Model files
touch lib/models/{order_model.dart,user_model.dart,print_settings.dart}

# Riverpod Providers
touch lib/providers/{auth_provider.dart,order_provider.dart,print_provider.dart,payment_provider.dart}

# Services (Firestore, Auth, Payment)
touch lib/services/{firestore_service.dart,auth_service.dart,payment_service.dart,storage_service.dart}

# Screens
touch lib/screens/auth/{login_screen.dart,register_screen.dart}
touch
