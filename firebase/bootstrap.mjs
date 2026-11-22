import { initializeApp, cert } from 'firebase-admin/app';
import { getFirestore } from 'firebase-admin/firestore';

const ORG_ID = 'gfg-kiit';

const args = process.argv.slice(2);
const presidentEmail = (args[0] || 'president@kiit.ac.in').toLowerCase();
const presidentName = args[1] || 'GFG President';

console.log(`==> Initializing SocietyOS Firestore Bootstrap for Org: ${ORG_ID}`);
console.log(`==> President Email: ${presidentEmail}`);
console.log(`==> President Name: ${presidentName}`);

initializeApp();
const db = getFirestore();
const orgRef = db.collection('orgs').doc(ORG_ID);

async function run() {
  const batch = db.batch();

  // 1. Organization Metadata
  batch.set(orgRef.collection('meta').doc('org'), {
    id: 'org',
    name: 'GeeksforGeeks KIIT Student Chapter',
    shortName: 'GFG KIIT',
    emailDomain: 'kiit.ac.in',
    currentTerm: '2025-26',
    recruitmentOpen: true,
    logoUrl: null,
    createdAt: new Date().toISOString()
  });

  // 2. Default Domains (Technical & Non-Technical)
  const domains = [
    { id: 'tech-sys', name: 'System Development', category: 'Technical' },
    { id: 'tech-cloud', name: 'Cloud Computing', category: 'Technical' },
    { id: 'tech-app', name: 'App Development', category: 'Technical' },
    { id: 'tech-web', name: 'Web Development', category: 'Technical' },
    { id: 'tech-cp', name: 'Competitive Programming', category: 'Technical' },
    { id: 'tech-bc', name: 'Blockchain', category: 'Technical' },
    { id: 'tech-ai', name: 'AI & Machine Learning', category: 'Technical' },
    { id: 'tech-sec', name: 'Cybersecurity', category: 'Technical' },
    { id: 'tech-game', name: 'Game Development', category: 'Technical' },
    { id: 'nontech-admin', name: 'Administration', category: 'Non-Technical' },
    { id: 'nontech-mkt', name: 'Marketing', category: 'Non-Technical' },
    { id: 'nontech-spon', name: 'Sponsorship & Public Relations', category: 'Non-Technical' },
    { id: 'nontech-design', name: 'UI/UX & Graphics', category: 'Non-Technical' },
    { id: 'nontech-media', name: 'Broadcasting & Media', category: 'Non-Technical' },
    { id: 'nontech-social', name: 'Social Media', category: 'Non-Technical' }
  ];

  for (const d of domains) {
    batch.set(orgRef.collection('domains').doc(d.id), d);
  }

  // 3. Default Roles
  const roles = [
    {
      id: 'president',
      name: 'President',
      tier: 'executive',
      rank: 1,
      permissions: ['all', 'manage_org', 'manage_finances', 'manage_roles', 'approve_expenses', 'post_announcements']
    },
    {
      id: 'vice_president',
      name: 'Vice President',
      tier: 'executive',
      rank: 2,
      permissions: ['all', 'manage_org', 'manage_finances', 'approve_expenses', 'post_announcements']
    },
    {
      id: 'treasurer',
      name: 'Treasurer',
      tier: 'executive',
      rank: 3,
      permissions: ['manage_finances', 'approve_expenses', 'view_wallet', 'audit_expenses']
    },
    {
      id: 'general_secretary',
      name: 'General Secretary',
      tier: 'executive',
      rank: 4,
      permissions: ['manage_events', 'manage_tasks', 'post_announcements', 'manage_meetings']
    },
    {
      id: 'core_head',
      name: 'Core Head',
      tier: 'core',
      rank: 5,
      permissions: ['verify_expenses', 'manage_department_tasks', 'post_domain_announcements']
    },
    {
      id: 'domain_lead',
      name: 'Domain Lead',
      tier: 'lead',
      rank: 6,
      permissions: ['review_expenses', 'assign_domain_tasks', 'review_applications']
    },
    {
      id: 'member',
      name: 'Member',
      tier: 'member',
      rank: 7,
      permissions: ['update_own_tasks', 'submit_expenses', 'view_events']
    },
    {
      id: 'guest',
      name: 'Guest',
      tier: 'guest',
      rank: 8,
      permissions: ['view_public_events', 'register_events']
    }
  ];

  for (const r of roles) {
    batch.set(orgRef.collection('roles').doc(r.id), r);
  }

  // 4. Invite President
  const inviteId = presidentEmail.replace(/[^a-z0-9]/g, '_');
  batch.set(orgRef.collection('invites').doc(inviteId), {
    id: inviteId,
    email: presidentEmail,
    roleId: 'president',
    name: presidentName,
    createdAt: new Date().toISOString()
  });

  await batch.commit();
  console.log('==> Bootstrap completed successfully!');
}

run().catch((err) => {
  console.error('==> Bootstrap error:', err);
  process.exit(1);
});
