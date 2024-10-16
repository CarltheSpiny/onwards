String convertNumbersAndSymbolsToWords(String input) {
  // Map for basic symbols
  final Map<String, String> symbolConversions = {
    '@': 'at',
    '#': 'hashtag',
    '&': 'and',
    '%': 'percent',
    '\$': 'dollar',
    '=' : 'equals',
    '+' : 'plus',
    '-' : 'subtract',
    '/' : 'divided by'
    // Add more symbols as needed
  };

  // Replace symbols with words
  String output = input;
  symbolConversions.forEach((symbol, word) {
    output = output.replaceAll(symbol, word);
  });

  // Replace numbers with words
  RegExp numberPattern = RegExp(r'\d+');
  output = output.replaceAllMapped(numberPattern, (match) {
    return convertNumberToWords(int.parse(match.group(0)!));
  });

  return output;
}

// Function to convert a number into words
String convertNumberToWords(int number) {
  if (number == 0) return 'zero';

  final belowTwenty = [
    '', 'one', 'two', 'three', 'four', 'five', 'six', 'seven', 'eight', 'nine',
    'ten', 'eleven', 'twelve', 'thirteen', 'fourteen', 'fifteen', 'sixteen', 'seventeen', 'eighteen', 'nineteen'
  ];

  final tens = ['', '', 'twenty', 'thirty', 'forty', 'fifty', 'sixty', 'seventy', 'eighty', 'ninety'];

  final thousands = ['', 'thousand', 'million', 'billion', 'trillion']; // Can extend for larger numbers

  String convertChunk(int num) {
    if (num == 0) return '';
    if (num < 20) return belowTwenty[num];
    if (num < 100) return tens[num ~/ 10] + (num % 10 != 0 ? ' ' + belowTwenty[num % 10] : '');
    return belowTwenty[num ~/ 100] + ' hundred' + (num % 100 != 0 ? ' ' + convertChunk(num % 100) : '');
  }

  String numberToWords(int num) {
    if (num == 0) return 'zero';

    int i = 0;
    String words = '';
    
    while (num > 0) {
      if (num % 1000 != 0) {
        words = convertChunk(num % 1000) + (thousands[i] != '' ? ' ' + thousands[i] : '') + (words.isNotEmpty ? ' ' + words : '');
      }
      num ~/= 1000;
      i++;
    }

    return words.trim();
  }

  return numberToWords(number);
}