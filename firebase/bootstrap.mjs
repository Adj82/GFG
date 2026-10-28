// One-time setup: writes the organisation, domains and roles to Firestore and
// invites the first President. Run it once, from this folder:
//
//   npm i firebase-admin
//   export GOOGLE_APPLICATION_CREDENTIALS=path/to/service-account.json
//   node bootstrap.mjs president@kiit.ac.in "Full Name"
//
// After that, the President signs in with Google and adds everyone else from
// People → Add member.
import { readFileSync } from 'node:fs';
import { initializeApp, applicationDefault } from 'firebase-admin/app';
import { getFirestore } from 'firebase-admin/firestore';

const [email, name = 'President'] = process.argv.slice(2);
if (!email || !email.toLowerCase().endsWith('@kiit.ac.in')) {
  console.error('Usage: node bootstrap.mjs <president@kiit.ac.in> ["Full Name"]');
  process.exit(1);
}

const ORG = 'gfg-kiit'; // must match kOrgId in lib/data/firebase/firestore_repository.dart
const data = JSON.parse(readFileSync(new URL('./bootstrap.json', import.meta.url)));

initializeApp({ credential: applicationDefault() });
const org = getFirestore().collection('orgs').doc(ORG);
const batch = getFirestore().batch();

batch.set(org.collection('meta').doc('org'), data.org);
for (const d of data.domains) batch.set(org.collection('domains').doc(d.id), d);
for (const r of data.roles) batch.set(org.collection('roles').doc(r.id), r);
batch.set(org.collection('invites').doc(email.toLowerCase()), {
  id: email.toLowerCase(),
  name,
  roleId: 'president',
  domainId: null,
  department: null,
  createdBy: 'bootstrap',
  createdAt: new Date().toISOString(),
});

await batch.commit();
console.log(`Done. ${data.domains.length} domains, ${data.roles.length} roles, president invited: ${email}`);
