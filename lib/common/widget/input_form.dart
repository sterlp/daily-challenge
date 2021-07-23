import 'package:flutter/material.dart';

// https://gist.github.com/rubensdemelo/6d441b0ce685581044a255842be25d0b
// https://chromium.googlesource.com/external/github.com/flutter/flutter/+/refs/heads/dev/packages/flutter/lib/src/material/text_form_field.dart
class InputForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final List<Widget> children;

  /// ```dart
  ///   InputForm(
  ///      formKey: _formKey,
  ///      children: <Widget>[
  ///        TextFormField(
  ///          autofocus: true,
  ///          inputFormatters: [LengthLimitingTextInputFormatter(Reward.NAME_LENGTH)],
  ///          controller: _nameController,
  ///          validator: (String v) => v.isNullOrEmpty ? 'Enter a reward name' : null,
  ///          decoration: new InputDecoration(
  ///              icon: MyStyle.GOAL_ICON,
  ///              hintText: "Enter reward name",
  ///              labelText: "Reward"
  ///          ),
  ///          textInputAction: TextInputAction.next,
  ///          onFieldSubmitted: (v) => FocusScope.of(context).nextFocus();
  ///        ),
  ///        TextFormField(
  ///          inputFormatters: [WhitelistingTextInputFormatter.digitsOnly],
  ///          controller: _costController,
  ///          validator: (String v) => v.isNullOrEmpty ? 'Enter a reward cost' : null,
  ///          textInputAction: TextInputAction.done,
  ///          decoration: new InputDecoration(
  ///            icon: MyStyle.COST_ICON,
  ///            hintText: "Enter the reward costs",
  ///            labelText: "Costs",
  ///          ),
  ///          keyboardType: TextInputType.number,
  ///          onFieldSubmitted: (v) => _save()
  ///        )
  ///      ],
  //      )
  // ```
  const InputForm({Key key, this.formKey, this.children}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FocusTraversalGroup(
        child: Form(
          key: formKey,
          autovalidate: true,
          onChanged: () {
            var form = Form.of(primaryFocus.context);
            if (form == null) form = formKey.currentState;
            if (form != null) form.save();
            // print('Save form $form ${formKey.currentState}');
          },
          child: ListView(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            children: children,
          )
        )
      )
    );
  }
}
