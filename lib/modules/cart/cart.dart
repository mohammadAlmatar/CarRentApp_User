import 'package:carent/layout/cubit/cubit.dart';
import 'package:carent/layout/cubit/states.dart';
import 'package:carent/modules/search/search_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import '../../models/cart_model/car_model.dart';
import '../../shared/componants/constants.dart';
import '../../shared/styles/icon_brokin.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MainCubit, MainStates>(
      listener: (context, state) {},
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            centerTitle: true,
            title: const Text(
              'My cart',
              style: TextStyle(fontFamily: 'jannah'),
            ),
            leading: IconButton(
              onPressed: () {
                ZoomDrawer.of(context)!.toggle();
              },
              icon: const Icon(
                IconBroken.Arrow___Left_2,
              ),
            ),
          ),
          body: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .doc(Constants.usersModel!.uId)
                        .collection('cart')
                        .snapshots(),
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot> carSnapshot) {
                      if (carSnapshot.hasError) {
                        return Text(
                          'Something is Wrong',
                          style: Constants.arabicTheme.textTheme.bodyLarge!
                              .copyWith(color: Colors.black),
                        );
                      }

                      if (carSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      return carSnapshot.data!.docs.isEmpty
                          ? SizedBox(
                              height: 250,
                              child: Center(
                                child: Text(
                                  "No Cars in the cart",
                                  style: Constants
                                      .arabicTheme.textTheme.bodyLarge!
                                      .copyWith(color: Colors.black),
                                ),
                              ),
                            )
                          : Column(
                              children: [
                                ListView(
                                  physics: const BouncingScrollPhysics(),
                                  scrollDirection: Axis.vertical,
                                  shrinkWrap: true,
                                  children: carSnapshot.data!.docs
                                      .map((DocumentSnapshot document) {
                                    Map<String, dynamic> data = document.data()!
                                        as Map<String, dynamic>;
                                    CarModel carModel = CarModel.fromJson(data);
                                    return Column(
                                      children: [
                                       SizedBox(
                                         width: 350.0,
                                         child: SearchCarCard(
                                           carModel: carModel,
                                           rented: true,
                                         ),
                                       ),
                                        const SizedBox(height: 10),
                                      ],
                                    );
                                  }).toList(),
                                ),
                              ],
                            );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
