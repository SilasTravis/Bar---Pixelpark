import 'package:flutter/widgets.dart';
import 'package:phosphor_icons/phosphor_icons.dart';

/// Maps a product's Phosphor icon class name (as typed in the Dashboard —
/// `ph ph-coffee`, `ph-coffee` or plain `coffee`) to a Flutter icon. Unknown
/// names fall back to a generic glass rather than failing: the Dashboard's
/// free-text icon field is the source of truth for which names exist.
IconData productIconFor(String icon) {
  final key = icon.trim().split(RegExp(r'\s+')).last.replaceFirst('ph-', '');
  return _icons[key] ?? PhosphorIconsRegular.martini;
}

const _icons = <String, IconData>{
  // drinks
  'coffee': PhosphorIconsRegular.coffee,
  'beer-bottle': PhosphorIconsRegular.beerBottle,
  'beer-stein': PhosphorIconsRegular.beerStein,
  'wine': PhosphorIconsRegular.wine,
  'martini': PhosphorIconsRegular.martini,
  'brandy': PhosphorIconsRegular.brandy,
  'pint-glass': PhosphorIconsRegular.pintGlass,
  'champagne': PhosphorIconsRegular.champagne,
  'drop': PhosphorIconsRegular.drop,
  'orange-slice': PhosphorIconsRegular.orangeSlice,
  // food & snacks
  'cookie': PhosphorIconsRegular.cookie,
  'candy': PhosphorIconsRegular.cookie,
  'hamburger': PhosphorIconsRegular.hamburger,
  'pizza': PhosphorIconsRegular.pizza,
  'bowl-food': PhosphorIconsRegular.bowlFood,
  'ice-cream': PhosphorIconsRegular.iceCream,
  'popcorn': PhosphorIconsRegular.popcorn,
  'cake': PhosphorIconsRegular.cake,
  'bread': PhosphorIconsRegular.bread,
  'cooking-pot': PhosphorIconsRegular.cookingPot,
  'fork-knife': PhosphorIconsRegular.forkKnife,
  // generic (same names the POS products use)
  'gift': PhosphorIconsRegular.gift,
  'shopping-bag': PhosphorIconsRegular.shoppingBag,
  'star': PhosphorIconsRegular.star,
  'heart': PhosphorIconsRegular.heart,
  'cube': PhosphorIconsRegular.cube,
  'package': PhosphorIconsRegular.package,
};
