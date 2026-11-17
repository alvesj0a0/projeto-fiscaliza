class MunicipioPara {
  final String nome;
  final String dre;
  final String regiao;

  const MunicipioPara({
    required this.nome,
    required this.dre,
    required this.regiao,
  });
}

class DadosPara {
  static const List<String> dres = [
    '01ª DRE - Belém',
    '02ª DRE - Ananindeua',
    '03ª DRE - Abaetetuba (Tocantins)',
    '04ª DRE - Marabá (Carajás)',
    '05ª DRE - Santarém (Baixo Amazonas)',
    '06ª DRE - Castanhal (Guamá)',
    '07ª DRE - Óbidos (Calha Norte)',
    '08ª DRE - Breves (Marajó)',
    '09ª DRE - Altamira (Xingu)',
    '10ª DRE - Capanema (Caeté)',
    '11ª DRE - Cametá',
    '12ª DRE - Itaituba (Tapajós)',
    '13ª DRE - Tucuruí',
    '14ª DRE - Parauapebas',
    '15ª DRE - Redenção (Araguaia)',
  ];

  static const List<MunicipioPara> municipios = [
    // Marajó
    MunicipioPara(
      nome: 'Breves',
      dre: '08ª DRE - Breves (Marajó)',
      regiao: 'Marajó',
    ),
    MunicipioPara(
      nome: 'Curralinho',
      dre: '08ª DRE - Breves (Marajó)',
      regiao: 'Marajó',
    ),
    MunicipioPara(
      nome: 'Anajás',
      dre: '08ª DRE - Breves (Marajó)',
      regiao: 'Marajó',
    ),
    MunicipioPara(
      nome: 'Portel',
      dre: '08ª DRE - Breves (Marajó)',
      regiao: 'Marajó',
    ),
    MunicipioPara(
      nome: 'Afuá',
      dre: '08ª DRE - Breves (Marajó)',
      regiao: 'Marajó',
    ),
    MunicipioPara(
      nome: 'Soure',
      dre: '08ª DRE - Breves (Marajó)',
      regiao: 'Marajó',
    ),

    // Região Metropolitana
    MunicipioPara(
      nome: 'Belém',
      dre: '01ª DRE - Belém',
      regiao: 'Metropolitana',
    ),
    MunicipioPara(
      nome: 'Ananindeua',
      dre: '02ª DRE - Ananindeua',
      regiao: 'Metropolitana',
    ),
    MunicipioPara(
      nome: 'Marituba',
      dre: '02ª DRE - Ananindeua',
      regiao: 'Metropolitana',
    ),
    MunicipioPara(
      nome: 'Benevides',
      dre: '02ª DRE - Ananindeua',
      regiao: 'Metropolitana',
    ),

    // Baixo Amazonas / Calha Norte
    MunicipioPara(
      nome: 'Santarém',
      dre: '05ª DRE - Santarém (Baixo Amazonas)',
      regiao: 'Baixo Amazonas',
    ),
    MunicipioPara(
      nome: 'Óbidos',
      dre: '07ª DRE - Óbidos (Calha Norte)',
      regiao: 'Baixo Amazonas',
    ),
    MunicipioPara(
      nome: 'Oriximiná',
      dre: '07ª DRE - Óbidos (Calha Norte)',
      regiao: 'Baixo Amazonas',
    ),

    // Carajás / Xingu
    MunicipioPara(
      nome: 'Marabá',
      dre: '04ª DRE - Marabá (Carajás)',
      regiao: 'Carajás',
    ),
    MunicipioPara(
      nome: 'Parauapebas',
      dre: '14ª DRE - Parauapebas',
      regiao: 'Carajás',
    ),
    MunicipioPara(
      nome: 'Altamira',
      dre: '09ª DRE - Altamira (Xingu)',
      regiao: 'Xingu',
    ),

    // Tocantins / Guamá
    MunicipioPara(
      nome: 'Abaetetuba',
      dre: '03ª DRE - Abaetetuba (Tocantins)',
      regiao: 'Tocantins',
    ),
    MunicipioPara(
      nome: 'Castanhal',
      dre: '06ª DRE - Castanhal (Guamá)',
      regiao: 'Guamá',
    ),
    MunicipioPara(nome: 'Cametá', dre: '11ª DRE - Cametá', regiao: 'Tocantins'),
  ];
}
