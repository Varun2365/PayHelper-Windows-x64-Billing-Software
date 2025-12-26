# 💼 PayHelper

<div align="center">

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Windows](https://img.shields.io/badge/Windows-0078D6?style=for-the-badge&logo=windows&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-blue?style=for-the-badge)

**A comprehensive billing and invoicing software designed for small businesses**

[Features](#-features) • [Installation](#-installation) • [Usage](#-usage) • [Screenshots](#-screenshots) • [Contributing](#-contributing)

</div>

---

## 📋 Table of Contents

- [About](#-about)
- [Features](#-features)
- [Tech Stack](#-tech-stack)
- [Installation](#-installation)
- [Usage](#-usage)
- [Project Structure](#-project-structure)
- [Contributing](#-contributing)
- [License](#-license)

## 🎯 About

**PayHelper** is a modern, user-friendly billing software built with Flutter that helps small businesses manage their invoicing, inventory, and financial records efficiently. With an intuitive interface and powerful features, PayHelper streamlines your business operations and keeps your financial data organized.

## ✨ Features

### 📄 Invoice Management
- **Create & Edit Invoices** - Generate professional invoices with customizable templates
- **Invoice Numbering** - Automatic invoice number generation with custom prefixes
- **PDF Export** - Export invoices as PDF files for easy sharing and printing
- **QR Code Integration** - Add QR codes to invoices for quick payment processing
- **GST Support** - Built-in GST calculation and compliance for Indian businesses

### 👥 Party Management
- **Customer Database** - Maintain a comprehensive database of customers and suppliers
- **Quick Access** - Fast search and retrieval of party information
- **Purchase Parties** - Separate management for purchase-related parties

### 📦 Product Management
- **Product Catalog** - Organize and manage your product inventory
- **Quick Add** - Add products on-the-fly while creating invoices
- **Product Details** - Store product information, prices, and descriptions

### 📊 Reports & Analytics
- **Sales Reports** - Generate detailed sales reports with visualizations
- **Purchase Records** - Track and manage purchase transactions
- **Excel Export** - Export data to Excel format for further analysis
- **Charts & Graphs** - Visual representation of your business data

### ⚙️ Settings & Customization
- **Firm Details** - Configure your business information, GST number, and address
- **Bank Details** - Add multiple bank account information
- **Terms & Conditions** - Customize invoice terms and conditions
- **Font Customization** - Adjust font sizes for better readability
- **Digital Signature** - Add your digital signature to invoices

### 🎨 User Interface
- **Responsive Design** - Optimized for large screens and desktop use
- **Modern UI** - Clean and professional interface with smooth animations
- **Custom Fonts** - Beautiful typography with multiple font families (Manrope, Poppins, Gilroy)
- **Dark/Light Theme Support** - Comfortable viewing experience

## 🛠 Tech Stack

### Core Technologies
- **Flutter** - Cross-platform UI framework
- **Dart** - Programming language

### Key Dependencies
- `pdf` - PDF generation and manipulation
- `qr_flutter` - QR code generation
- `excel` & `syncfusion_flutter_xlsio` - Excel file creation
- `fl_chart` - Beautiful charts and graphs
- `intl` - Internationalization and date formatting
- `path_provider` - File system access
- `file_picker` - File selection and management
- `pdfrx` - PDF viewing capabilities
- `indian_currency_to_word` - Currency to words conversion

### Data Storage
- **JSON Files** - Lightweight, file-based data storage
- Local file system for data persistence

## 📦 Installation

### Prerequisites
- Flutter SDK (>=3.4.0)
- Dart SDK
- Windows OS (currently optimized for Windows)

### Setup Instructions

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/payhelper.git
   cd payhelper
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the application**
   ```bash
   flutter run
   ```

4. **Build for Windows**
   ```bash
   flutter build windows
   ```

## 🚀 Usage

### Getting Started

1. **First Launch**
   - The application will automatically create necessary database folders and files
   - You'll be prompted to set up your firm details

2. **Configure Firm Settings**
   - Navigate to Settings page
   - Enter your business information:
     - Firm name and GST number
     - Business address
     - Bank account details
     - Terms and conditions
     - UPI QR code details

3. **Add Products**
   - Go to Products page
   - Add your product catalog with prices and descriptions

4. **Add Parties**
   - Navigate to Parties page
   - Add your customers and suppliers

5. **Create Invoices**
   - Click on "Create Invoice" from the navigation bar
   - Select a party, add products, and generate your invoice
   - Export as PDF or print directly

### Key Workflows

- **Creating an Invoice**: Home → Create Invoice → Select Party → Add Items → Generate PDF
- **Managing Products**: Products → Add/Edit Products
- **Viewing Reports**: Reports → Select Report Type → View Analytics
- **Purchase Records**: Purchase → Add Purchase Entry → Track Expenses

## 📁 Project Structure

```
payhelper/
├── lib/
│   ├── main.dart                 # Application entry point
│   ├── colors.dart               # Color palette definitions
│   ├── constants.dart            # App constants
│   ├── components/               # Reusable UI components
│   ├── Handlers/                 # Data handlers (JSON)
│   ├── Pages/                    # Main application pages
│   ├── NavBar/                   # Navigation components
│   ├── InvoicesPageSection/     # Invoice management
│   ├── PartiesPage/              # Party management
│   ├── ProductsPage/             # Product management
│   ├── ReportsPage/              # Reports and analytics
│   ├── Settings Page/             # Settings and configuration
│   └── SplashScreen/             # Splash screen
├── assets/
│   ├── fonts/                    # Custom fonts
│   └── images/                   # Images and icons
├── Database/                     # Local data storage
│   ├── Firm/                     # Firm details
│   ├── Invoices/                 # Invoice data
│   ├── Party Records/            # Party information
│   ├── Products/                 # Product catalog
│   └── PDF/                      # Generated PDFs
└── windows/                      # Windows-specific files
```

## 🤝 Contributing

Contributions are welcome! If you'd like to contribute to PayHelper:

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

### Development Guidelines
- Follow Flutter/Dart best practices
- Maintain code readability and documentation
- Test your changes thoroughly
- Update README if needed

## 📝 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- All the open-source package contributors
- The small business community for inspiration

---

<div align="center">

**Made with ❤️ for small businesses**

⭐ Star this repo if you find it helpful!

</div>
