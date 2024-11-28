import 'package:appis_app/assets/colors/colors.dart';
import 'package:flutter/material.dart';


InputDecoration getAuthenticationInputDecoration(String label, {Icon? icon}) {
  return InputDecoration(
    icon: icon,
    hintText: label,
    fillColor:  Colors.white,
    filled:  true,
    border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    enabledBorder: OutlineInputBorder(borderRadius:BorderRadius.circular(64),
    borderSide: const BorderSide(color: Colors.black, width:2),
    ),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(64),
    borderSide: const BorderSide(color: paletaDeCores.amareloEscuro ,width: 4),
    ),
    errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(64),
    borderSide: const BorderSide(color: Colors.red, width: 2),
    ),
    focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(64),
    borderSide: const BorderSide(color: Colors.red, width: 4),
 ),
  );
  
  }