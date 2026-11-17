enum TipoOpcaoResposta { simNao, conformeDivergente, texto, quantidade }

class PerguntaFormulario {
  final String id;
  final String bloco; // Ex: Armazenamento, Higiene, Veículo, Condutor
  final String enunciado;
  final String? orientacaoFiscal;
  final bool ehCritico; // Se 'Não/Divergente' gera alerta de infração grave

  const PerguntaFormulario({
    required this.id,
    required this.bloco,
    required this.enunciado,
    this.orientacaoFiscal,
    this.ehCritico = false,
  });
}

class ChecklistFormularios {
  // --- FORMULÁRIO COMPLETO PEAE (ALIMENTAÇÃO ESCOLAR) ---
  static const List<PerguntaFormulario> perguntasPEAE = [
    // Bloco 1: Depósito / Almoxarifado / Despensa
    PerguntaFormulario(
      id: 'peae_01',
      bloco: 'Armazenamento e Despensa',
      enunciado:
          'O local de armazenamento de alimentos está limpo, arejado e livre de insetos/roedores?',
      orientacaoFiscal:
          'Verificar presença de estrados/paletes e ausência de umidade.',
      ehCritico: true,
    ),
    PerguntaFormulario(
      id: 'peae_02',
      bloco: 'Armazenamento e Despensa',
      enunciado:
          'Os alimentos estão dispostos sobre paletes/prateleiras (sem contato direto com o chão)?',
      orientacaoFiscal: 'Distância mínima de 10 cm do piso e das paredes.',
      ehCritico: false,
    ),
    PerguntaFormulario(
      id: 'peae_03',
      bloco: 'Validade e Qualidade',
      enunciado:
          'Há produtos com prazo de validade vencido ou sem identificação de lote no estoque?',
      orientacaoFiscal:
          'Checar sacos de arroz, feijão, leite em pó e latas de óleo.',
      ehCritico: true,
    ),

    // Bloco 2: Cozinha e Preparo
    PerguntaFormulario(
      id: 'peae_04',
      bloco: 'Cozinha e Manipulação',
      enunciado:
          'As merendeiras utilizam equipamentos de proteção individual (EPI) como touca e avental?',
      orientacaoFiscal:
          'Verificar condições de higiene pessoal das manipuladoras de alimento.',
      ehCritico: false,
    ),
    PerguntaFormulario(
      id: 'peae_05',
      bloco: 'Cozinha e Manipulação',
      enunciado:
          'A água utilizada no preparo das refeições e para beber é potável e filtrada?',
      orientacaoFiscal:
          'Observar a limpeza da caixa d’água e filtros operacionais.',
      ehCritico: true,
    ),

    // Bloco 3: Cardápio e Distribuição
    PerguntaFormulario(
      id: 'peae_06',
      bloco: 'Cardápio e Aceitabilidade',
      enunciado:
          'A refeição servida no dia está de acordo com o cardápio planejado pelo nutricionista da SEDUC?',
      orientacaoFiscal:
          'Comparar o cardápio afixado com o alimento servido aos alunos.',
      ehCritico: false,
    ),
    PerguntaFormulario(
      id: 'peae_07',
      bloco: 'Cardápio e Aceitabilidade',
      enunciado:
          'Há registro de contaminação, avaria na embalagem ou perecimento prévio de insumos da agricultura familiar?',
      orientacaoFiscal: 'Inspecionar frutas, verduras e polpas recebidas.',
      ehCritico: true,
    ),
  ];

  // --- FORMULÁRIO COMPLETO PETE (TRANSPORTE ESCOLAR) ---
  static const List<PerguntaFormulario> perguntasPETE = [
    // Bloco 1: Veículo / Embarcação (Fluvial ou Terrestre)
    PerguntaFormulario(
      id: 'pete_01',
      bloco: 'Condições do Veículo/Embarcação',
      enunciado:
          'O veículo/embarcação possui identificação visível "TRANSPORTE ESCOLAR"?',
      orientacaoFiscal:
          'Faixa amarela com dístico preto em veículos ou pintura regulamentar em lanchas.',
      ehCritico: false,
    ),
    PerguntaFormulario(
      id: 'pete_02',
      bloco: 'Equipamentos de Segurança',
      enunciado:
          'Há coletes salva-vidas (fluvial) ou cintos de segurança (terrestre) em quantidade 100% suficiente para todos os alunos?',
      orientacaoFiscal:
          'Contar o número de assentos/alunos vs. número de coletes/cintos disponíveis em bom estado.',
      ehCritico: true,
    ),
    PerguntaFormulario(
      id: 'pete_03',
      bloco: 'Lotação e Capacidade',
      enunciado:
          'A lotação de alunos respeita a capacidade máxima homologada do veículo/embarcação?',
      orientacaoFiscal:
          'Verificar se há alunos em pé ou excesso de lotação no convés/banco.',
      ehCritico: true,
    ),

    // Bloco 2: Condutor e Habilitação
    PerguntaFormulario(
      id: 'pete_04',
      bloco: 'Habilitação do Condutor',
      enunciado:
          'O condutor/piloto possui habilitação/ARRAIS compatível válida e curso de transporte escolar registrado?',
      orientacaoFiscal:
          'Solicitar CNH Categoria D/E (terrestre) ou Carteira da Capitania dos Portos (se for fluvial).',
      ehCritico: true,
    ),

    // Bloco 3: Rota e Pontualidade
    PerguntaFormulario(
      id: 'pete_05',
      bloco: 'Cumprimento de Rota',
      enunciado:
          'A rota cadastrada está sendo cumprida integralmente sem desvios não autorizados?',
      orientacaoFiscal:
          'Conferir com os estudantes e direção escolar o horário de chegada e saída.',
      ehCritico: false,
    ),
  ];
}
