/// Pastèque-Match data preparation
/// Node.js script to compute phonetics
///
/// 1. Add list of names in a input.txt file
/// 2. Run "node.exe .\main.js"
/// 3. A output.txt file is created containing results

// Read input file
import * as fs from 'fs';
var input = fs.readFileSync('input.txt', 'utf8');

// Build list of names
var names = input.split('\n');

// Compute fonem values
import fonem from 'talisman/phonetics/french/fonem.js';
var fonemResult = [];
for (var name of names) {
    fonemResult.push(fonem(name));
}

// Compute phonetic values
import phonetic from 'talisman/phonetics/french/phonetic.js';
var phoneticResult = [];
for (var name of names) {
    phoneticResult.push(phonetic(name));
}

// Output
var output = `
------ fonem -----
${fonemResult.join('\n')}

------ phonetic -----
${phoneticResult.join('\n')}
`;

// Write to file (too large for console)
try {
  fs.writeFileSync('output.txt', output);
} catch (err) {
  console.error(err);
}
console.log('Success !');
