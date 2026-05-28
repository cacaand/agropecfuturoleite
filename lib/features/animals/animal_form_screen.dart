import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import '../../database/database.dart';
import '../../main.dart';

class AnimalFormScreen extends ConsumerStatefulWidget {
  final String? animalId;
  const AnimalFormScreen({super.key, this.animalId});
  @override
  ConsumerState<AnimalFormScreen> createState() => _State();
}

class _State extends ConsumerState<AnimalFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _code    = TextEditingController();
  final _name    = TextEditingController();
  final _earTag  = TextEditingController();
  final _breed   = TextEditingController();
  final _weight  = TextEditingController();
  final _notes   = TextEditingController();
  String _sex      = 'FEMALE';
  String _category = 'DAIRY_COW';
  String _status   = 'ACTIVE';
  DateTime? _birthDate;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    if (widget.animalId != null) _load();
  }

  Future<void> _load() async {
    final db = ref.read(dbProvider);
    final list = await db.watchAnimals().first;
    final a = list.where((x) => x.id == widget.animalId).firstOrNull;
    if (a != null && mounted) setState(() {
      _code.text   = a.code;
      _name.text   = a.name ?? '';
      _earTag.text = a.earTag ?? '';
      _breed.text  = a.breed;
      _weight.text = a.weight?.toString() ?? '';
      _notes.text  = a.notes ?? '';
      _sex      = a.sex;
      _category = a.category;
      _status   = a.status;
      _birthDate = a.birthDate;
    });
  }

  @override
  void dispose() {
    _code.dispose(); _name.dispose(); _earTag.dispose();
    _breed.dispose(); _weight.dispose(); _notes.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final db = ref.read(dbProvider);
    try {
      final data = <String, dynamic>{
        'code':      _code.text.trim(),
        'name':      _name.text.trim().isEmpty ? null : _name.text.trim(),
        'earTag':    _earTag.text.trim().isEmpty ? null : _earTag.text.trim(),
        'breed':     _breed.text.trim(),
        'sex':       _sex,
        'category':  _category,
        'status':    _status,
        'weight':    _weight.text.trim().isEmpty ? null : double.tryParse(_weight.text.trim()),
        'notes':     _notes.text.trim().isEmpty ? null : _notes.text.trim(),
        'birthDate': _birthDate?.toIso8601String(),
        'isDeleted': 0,
      };
      if (widget.animalId == null) {
        data['createdAt'] = DateTime.now().toIso8601String();
        await db.insertAnimal(data);
      } else {
        await db.updateAnimal(widget.animalId!, data);
      }
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: $e'), backgroundColor: AppColors.red600));
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.gray50,
      appBar: AppBar(
        backgroundColor: Colors.white, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded, color: AppColors.gray700), onPressed: () => context.pop()),
        title: Text(widget.animalId == null ? 'Novo Animal' : 'Editar Animal',
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.gray900)),
        actions: [
          Padding(padding: const EdgeInsets.only(right: 16),
            child: _loading
              ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: AppColors.green700, strokeWidth: 2))
              : ElevatedButton(onPressed: _save, child: const Text('Salvar'))),
        ],
        bottom: const PreferredSize(preferredSize: Size.fromHeight(0.5),
          child: Divider(height: 0.5, color: AppColors.gray200)),
      ),
      body: Form(
        key: _formKey,
        child: ListView(padding: const EdgeInsets.all(16), children: [
          _Card('Identificação', [
            _Field(_code,  'Código *',          '0001',       required: true),
            _Field(_name,  'Nome',               'Mimosa'),
            _Field(_earTag,'Brinco / SISBOV',    'BRZ-0001'),
          ]),
          const SizedBox(height: 12),
          _Card('Dados do Animal', [
            _Field(_breed, 'Raça *', 'Holandesa, Girolando...', required: true),
            _Drop('Sexo', _sex, {'FEMALE': 'Fêmea', 'MALE': 'Macho'}, (v) => setState(() => _sex = v!)),
            _Drop('Categoria', _category, {
              'DAIRY_COW': 'Vaca Leiteira', 'HEIFER': 'Novilha',
              'CALF': 'Bezerra(o)', 'BULL': 'Touro', 'DRY_COW': 'Vaca Seca',
            }, (v) => setState(() => _category = v!)),
            _Drop('Status', _status, {
              'ACTIVE': 'Ativa', 'PREGNANT': 'Prenhe', 'DRY': 'Seca', 'SICK': 'Doente',
            }, (v) => setState(() => _status = v!)),
          ]),
          const SizedBox(height: 12),
          _Card('Medidas e Datas', [
            _Field(_weight, 'Peso atual (kg)', '500', type: TextInputType.number),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                _birthDate == null ? 'Data de nascimento' : 'Nascimento: ${_birthDate!.day}/${_birthDate!.month}/${_birthDate!.year}',
                style: TextStyle(fontSize: 13, color: _birthDate == null ? AppColors.gray400 : AppColors.gray800)),
              trailing: const Icon(Icons.calendar_today_rounded, color: AppColors.green700, size: 18),
              onTap: () async {
                final d = await showDatePicker(context: context,
                  initialDate: DateTime(2021), firstDate: DateTime(2000), lastDate: DateTime.now(),
                  builder: (c, child) => Theme(data: Theme.of(c).copyWith(
                    colorScheme: const ColorScheme.light(primary: AppColors.green700)), child: child!));
                if (d != null) setState(() => _birthDate = d);
              },
            ),
          ]),
          const SizedBox(height: 12),
          _Card('Observações', [
            TextFormField(controller: _notes, maxLines: 3,
              style: const TextStyle(fontSize: 13),
              decoration: const InputDecoration(hintText: 'Observações adicionais...')),
          ]),
        ]),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final String title; final List<Widget> children;
  const _Card(this.title, this.children);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppColors.gray200, width: 0.5)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.gray700)),
      const SizedBox(height: 12),
      ...children,
    ]),
  );
}

class _Field extends StatelessWidget {
  final TextEditingController ctrl; final String label, hint;
  final bool required; final TextInputType type;
  const _Field(this.ctrl, this.label, this.hint, {this.required = false, this.type = TextInputType.text});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextFormField(controller: ctrl, keyboardType: type,
      style: const TextStyle(fontSize: 13),
      decoration: InputDecoration(labelText: label, hintText: hint),
      validator: required ? (v) => (v == null || v.isEmpty) ? 'Campo obrigatório' : null : null),
  );
}

class _Drop extends StatelessWidget {
  final String label, value; final Map<String, String> items; final void Function(String?) onChanged;
  const _Drop(this.label, this.value, this.items, this.onChanged);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(labelText: label),
      style: const TextStyle(fontSize: 13, color: AppColors.gray800),
      items: items.entries.map((e) => DropdownMenuItem(value: e.key, child: Text(e.value))).toList(),
      onChanged: onChanged),
  );
}
