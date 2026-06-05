import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../models/booking.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_textfield.dart';
import '../../core/animations/fade_slide_transition.dart';
import '../../core/animations/scale_transition_wrapper.dart';
import '../../providers/app_state_provider.dart';
import 'payment_success_screen.dart';

enum PaymentMethod {
  card,
  wallet,
  mobileMoney,
  cash,
}

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({Key? key}) : super(key: key);

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  PaymentMethod _selectedMethod = PaymentMethod.card;
  final _formKey = GlobalKey<FormState>();
  
  // Card ke controllers
  final _cardNumberController = TextEditingController(text: "5420 8890 1204 5671");
  final _cardHolderController = TextEditingController(text: "Alex Rivera");
  final _cardExpiryController = TextEditingController(text: "08/29");
  final _cardCvvController = TextEditingController(text: "349");

  bool _isPaying = false;

  void _cardNumberListener() => setState(() {});
  void _cardHolderListener() => setState(() {});
  void _cardExpiryListener() => setState(() {});
  void _cardCvvListener() => setState(() {});

  @override
  void initState() {
    super.initState();
    _cardNumberController.addListener(_cardNumberListener);
    _cardHolderController.addListener(_cardHolderListener);
    _cardExpiryController.addListener(_cardExpiryListener);
    _cardCvvController.addListener(_cardCvvListener);
  }

  @override
  void dispose() {
    _cardNumberController.dispose();
    _cardHolderController.dispose();
    _cardExpiryController.dispose();
    _cardCvvController.dispose();
    super.dispose();
  }

  void _processPayment() async {
    if (_selectedMethod == PaymentMethod.card && !_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isPaying = true;
    });

    final state = Provider.of<AppStateProvider>(context, listen: false);
    final stayDays = state.checkOutDate.difference(state.checkInDate).inDays;
    final double price = (state.selectedRoomForBooking?.pricePerNight ?? 100.0) * (stayDays <= 0 ? 1 : stayDays);

    // Payment ko string form mein lana
    // Payment method ka label set karna
    String methodLabel = "Credit Card";
    if (_selectedMethod == PaymentMethod.wallet) methodLabel = "SARTE Wallet";
    if (_selectedMethod == PaymentMethod.mobileMoney) methodLabel = "Mobile Wallet";
    if (_selectedMethod == PaymentMethod.cash) methodLabel = "Cash on Arrival";

    try {
      // Database booking integration ko background mein chalana
      final String bookingId = await state.createBookingInDb(
        roomId: int.parse(state.selectedRoomForBooking!.id),
        guestName: state.userName,
        guestEmail: state.userEmail,
        checkIn: state.checkInDate,
        checkOut: state.checkOutDate,
        guestCount: state.guestCount,
        totalPrice: price,
        paymentMethod: methodLabel,
      );

      if (mounted) {
        final newBooking = Booking(
          id: bookingId,
          room: state.selectedRoomForBooking!,
          guestName: state.userName,
          guestEmail: state.userEmail,
          checkIn: state.checkInDate,
          checkOut: state.checkOutDate,
          guestCount: state.guestCount,
          totalPrice: price,
          bookingDate: DateTime.now(),
          paymentMethod: methodLabel,
          status: BookingStatus.upcoming,
        );

        // Success screen par jana
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => PaymentSuccessScreen(booking: newBooking),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 600),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.error,
            content: Text(
              "Checkout Error: ${e.toString().replaceAll("Exception: ", "")}",
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isPaying = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final state = Provider.of<AppStateProvider>(context);

    final stayDays = state.checkOutDate.difference(state.checkInDate).inDays;
    final double roomCost = (state.selectedRoomForBooking?.pricePerNight ?? 100.0);
    final double totalPrice = roomCost * (stayDays <= 0 ? 1 : stayDays);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: isDark ? AppColors.white : AppColors.black,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "SECURE CHECKOUT",
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
        ),
        centerTitle: true,
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Peeche ki ambient lights
          if (isDark) ...[
            Positioned(
              top: -100,
              left: -50,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.06),
                      blurRadius: 90,
                    ),
                  ],
                ),
              ),
            ),
          ],

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Payment method selector ki horizontal line
                  FadeSlideTransition(
                    slideOffset: 20,
                    delay: const Duration(milliseconds: 50),
                    child: Row(
                      children: [
                        _methodTab(PaymentMethod.card, Icons.credit_card_rounded, "CARD"),
                        _methodTab(PaymentMethod.wallet, Icons.wallet_rounded, "WALLET"),
                        _methodTab(PaymentMethod.mobileMoney, Icons.phone_android_rounded, "MOBILE"),
                        _methodTab(PaymentMethod.cash, Icons.payments_rounded, "CASH"),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Dynamic Method View ka panel
                  if (_selectedMethod == PaymentMethod.card) ...[
                    // Virtual premium 3D styled card ka mockup
                    FadeSlideTransition(
                      slideOffset: 30,
                      delay: const Duration(milliseconds: 100),
                      child: _buildCreditCardMockup(),
                    ),
                    const SizedBox(height: 24),
                    
                    // Glassmorphism ke andar Card Form ke Inputs
                    FadeSlideTransition(
                      slideOffset: 30,
                      delay: const Duration(milliseconds: 150),
                      child: GlassCard(
                        opacity: isDark ? 0.08 : 0.45,
                        borderColor: AppColors.glassBorderWhite,
                        padding: const EdgeInsets.all(20),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "CARD INFORMATION",
                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                              ),
                              const Divider(height: 24, thickness: 0.5),
                              
                              CustomTextField(
                                labelText: "Cardholder Name",
                                hintText: "Alex Rivera",
                                controller: _cardHolderController,
                                prefixIcon: Icons.person_outline,
                                validator: (v) => v!.trim().isEmpty ? "Cardholder name is required" : null,
                              ),
                              const SizedBox(height: 16),
                              
                              CustomTextField(
                                labelText: "Card Number",
                                hintText: "5420 8890 1204 5671",
                                controller: _cardNumberController,
                                keyboardType: TextInputType.number,
                                prefixIcon: Icons.credit_card_outlined,
                                validator: (v) => v!.trim().isEmpty ? "Card number is required" : null,
                              ),
                              const SizedBox(height: 16),
                              
                              Row(
                                children: [
                                  Expanded(
                                    child: CustomTextField(
                                      labelText: "Expiry Date",
                                      hintText: "MM/YY",
                                      controller: _cardExpiryController,
                                      keyboardType: TextInputType.datetime,
                                      prefixIcon: Icons.calendar_today_outlined,
                                      validator: (v) => v!.trim().isEmpty ? "Required" : null,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: CustomTextField(
                                      labelText: "Secure CVV",
                                      hintText: "•••",
                                      controller: _cardCvvController,
                                      keyboardType: TextInputType.number,
                                      prefixIcon: Icons.lock_outline,
                                      validator: (v) => v!.trim().isEmpty ? "Required" : null,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ] else if (_selectedMethod == PaymentMethod.wallet) ...[
                    FadeSlideTransition(
                      slideOffset: 30,
                      child: _buildWalletView(isDark),
                    ),
                  ] else if (_selectedMethod == PaymentMethod.mobileMoney) ...[
                    FadeSlideTransition(
                      slideOffset: 30,
                      child: _buildMobileMoneyView(isDark),
                    ),
                  ] else if (_selectedMethod == PaymentMethod.cash) ...[
                    FadeSlideTransition(
                      slideOffset: 30,
                      child: _buildCashView(isDark),
                    ),
                  ],
                  const SizedBox(height: 24),

                  // Receipt ki Summary ka Card
                  FadeSlideTransition(
                    slideOffset: 20,
                    delay: const Duration(milliseconds: 200),
                    child: GlassCard(
                      opacity: isDark ? 0.04 : 0.35,
                      borderColor: AppColors.glassBorderWhite,
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "BILLING STATEMENT",
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                          ),
                          const Divider(height: 24, thickness: 0.5),
                          _receiptRow("Suite Base Price", "\$$roomCost / night"),
                          const SizedBox(height: 8),
                          _receiptRow("Stay Length", "$stayDays Night${stayDays > 1 ? 's' : ''}"),
                          const SizedBox(height: 8),
                          _receiptRow("Service & Facility Taxes", "\$0.00 (Waived)"),
                          const Divider(height: 24, thickness: 0.5),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "TOTAL SECURED PAYMENT",
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                              Text(
                                "\$${totalPrice.toInt()}",
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 36),

                  // Booking lock karne wala button
                  FadeSlideTransition(
                    slideOffset: 10,
                    delay: const Duration(milliseconds: 250),
                    child: CustomButton(
                      text: _isPaying ? "AUTHORIZING SECURE GATEWAY..." : "CONFIRM & AUTHORIZE",
                      type: ButtonType.primary,
                      isLoading: _isPaying,
                      onTap: _processPayment,
                    ),
                  ),
                  const SizedBox(height: 36),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _methodTab(PaymentMethod method, IconData icon, String label) {
    final isSelected = _selectedMethod == method;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: ScaleTransitionWrapper(
        onTap: () {
          setState(() {
            _selectedMethod = method;
          });
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary
                : (isDark ? AppColors.glassWhite : Colors.black.withOpacity(0.04)),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected
                  ? AppColors.primary
                  : (isDark ? AppColors.glassBorderWhite : Colors.black.withOpacity(0.08)),
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected ? AppColors.black : (isDark ? Colors.white : Colors.black),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                  color: isSelected ? AppColors.black : (isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Premium glass credit card ka mockup
  Widget _buildCreditCardMockup() {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xFF2E2F23), Color(0xFF0F100B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: AppColors.glassBorderGold, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.12),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "SARTE PLATINUM DECK",
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                  Text(
                    "PLATINUM MEMBER",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.4),
                      fontSize: 7,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
              Container(
                width: 38,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                alignment: Alignment.center,
                child: const Icon(Icons.credit_card, color: Colors.white70, size: 14),
              ),
            ],
          ),
          
          Text(
            _cardNumberController.text.isEmpty ? "•••• •••• •••• ••••" : _cardNumberController.text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 2.0,
              fontFamily: "Courier",
            ),
          ),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "CARDHOLDER",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.4),
                      fontSize: 7,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _cardHolderController.text.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "EXPIRES",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.4),
                          fontSize: 7,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _cardExpiryController.text.isEmpty ? "MM/YY" : _cardExpiryController.text,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "CVV",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.4),
                          fontSize: 7,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _cardCvvController.text.isEmpty ? "•••" : _cardCvvController.text,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWalletView(bool isDark) {
    return GlassCard(
      opacity: isDark ? 0.08 : 0.45,
      borderColor: AppColors.glassBorderWhite,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "SARTE WALLET",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  "ACTIVE BALANCE",
                  style: TextStyle(color: AppColors.success, fontSize: 9, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const Divider(height: 32, thickness: 0.5),
          const Text(
            "\$980.50",
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Account: Alex Rivera • Member ID #99014",
            style: TextStyle(
              fontSize: 11,
              color: isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.glassBorderGold),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: AppColors.primary, size: 16),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "Payments via the SARTE loyalty wallet receive immediate clearance and are eligible for reward points.",
                    style: TextStyle(
                      fontSize: 10,
                      color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Mobile money wallets ka view (JazzCash, Easypaisa, Zindagi)
  Widget _buildMobileMoneyView(bool isDark) {
    return GlassCard(
      opacity: isDark ? 0.08 : 0.45,
      borderColor: AppColors.glassBorderWhite,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "MOBILE WALLET PARTNERS",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1),
          ),
          const Divider(height: 32, thickness: 0.5),
          
          // Wallet payment ke liye Mobile number ka field
          const CustomTextField(
            labelText: "Enter Mobile Wallet Number",
            hintText: "03XX XXXXXXX",
            prefixIcon: Icons.phone_android_rounded,
          ),
          const SizedBox(height: 20),
          
          Text(
            "SELECT PAYMENT PARTNER",
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 12),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _mobilePartnerIcon("JazzCash", const Color(0xFFE2192C)),
              _mobilePartnerIcon("Easypaisa", const Color(0xFF4CAF50)),
              _mobilePartnerIcon("Zindagi", const Color(0xFF1E88E5)),
            ],
          ),
        ],
      ),
    );
  }

  // Mobile wallet partner ka icon widget
  Widget _mobilePartnerIcon(String name, Color col) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.glassWhite,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.glassBorderWhite),
        ),
        alignment: Alignment.center,
        child: Text(
          name,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: col,
          ),
        ),
      ),
    );
  }

  Widget _buildCashView(bool isDark) {
    return GlassCard(
      opacity: isDark ? 0.08 : 0.45,
      borderColor: AppColors.glassBorderWhite,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "CASH PAY ON DEPARTURE",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1),
          ),
          const Divider(height: 32, thickness: 0.5),
          const Text(
            "Verify with Valid ID",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            "When selecting 'Cash on Departure', you must present a valid government-issued ID at the reception lobby upon arrival. SARTE reserves the right to authorize credit hold deposits.",
            style: TextStyle(
              fontSize: 11,
              color: isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _receiptRow(String name, String price) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          name,
          style: const TextStyle(fontSize: 12),
        ),
        Text(
          price,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
