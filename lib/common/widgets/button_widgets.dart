import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:facemark/common/utils/app_colors.dart';
import 'package:facemark/common/widgets/app_shadow.dart';
import 'package:facemark/common/widgets/text_widgets.dart';
import 'package:facemark/pages/sign_in/widgets/sign_in_widgets.dart';
import 'package:facemark/pages/sign_up/sign_up.dart';

import 'app_bar.dart';

Widget appButton({
  double width = 325,
  double height = 50,
  String buttonName = "",
  bool isLogin = true,
  BuildContext? context,
  void Function()? func
}) {
  return GestureDetector(
    onTap: func,
    child: Container(
      width: width.w,
      height: height.h,
      //isLogin true then send primary color else send white color
      decoration: appBoxShadow(
          color: isLogin ? AppColors.primaryElement : Colors.white,
          border: Border.all(color: AppColors.primaryFourthElementText)),
      child: Center(
          child: text16Normal(
              text: buttonName,
              color: isLogin
                  ? AppColors.primaryBackground
                  : AppColors.primaryText)),
    ),
  );
}
