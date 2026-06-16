

import "package:flutter/material.dart";

class AnimatedTransactionItem extends StatefulWidget{
  final Widget child;
  final int index;

  const AnimatedTransactionItem({super.key, required this.child, required this.index});
  
State<AnimatedTransactionItem> createState() => _AnimatedTransactionItemState();
  

}
class _AnimatedTransactionItemState extends State<AnimatedTransactionItem> with SingleTickerProviderStateMixin {
  @override

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

    @override
    void initState(){
      super.initState();
      final delay=Duration(milliseconds: widget.index*50);
      _controller=AnimationController(
        duration: Duration(milliseconds: 400),
        
        vsync: this);

        _fadeAnimation=CurvedAnimation(
          parent: _controller,
           curve: Curves.easeOutCubic);

        // _slideAnimation=Tween<Offset>()
    }
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
  
}