import React, { useState } from 'react';
import './index.css';

// ─── Types ───────────────────────────────────────────────────────────────────

interface MenuItem { id: number; name: string; price: number; category: string; }
interface Restaurant {
  id: number; name: string; location: string;
  description: string; image: string; status: string;
  menu: MenuItem[];
}

// ─── Confirmation Dialog ──────────────────────────────────────────────────────

const ConfirmModal = ({ show, message, onConfirm, onCancel }: any) => {
  if (!show) return null;
  return (
    <div className="fixed inset-0 z-[100] flex items-center justify-center p-6" style={{ background: 'rgba(15,23,42,0.6)', backdropFilter: 'blur(8px)' }}>
      <div className="bg-white rounded-3xl p-10 max-w-sm w-full shadow-2xl" style={{ boxShadow: '0 32px 64px -8px rgba(0,0,0,0.3)' }}>
        <div className="w-16 h-16 bg-red-50 rounded-2xl flex items-center justify-center text-3xl mx-auto mb-6">⚠️</div>
        <h3 className="text-2xl font-black text-slate-900 text-center mb-3">Are you sure?</h3>
        <p className="text-slate-500 text-center mb-8 leading-relaxed">{message}</p>
        <div className="flex gap-3">
          <button onClick={onCancel} className="flex-1 py-4 rounded-2xl border-2 border-slate-200 text-slate-600 font-black text-sm hover:bg-slate-50 transition-colors">
            Cancel
          </button>
          <button onClick={onConfirm} className="flex-1 py-4 rounded-2xl bg-red-500 text-white font-black text-sm hover:bg-red-600 transition-colors" style={{ boxShadow: '0 8px 24px -4px rgba(239,68,68,0.4)' }}>
            Delete
          </button>
        </div>
      </div>
    </div>
  );
};

// ─── Stat Card ────────────────────────────────────────────────────────────────

const StatCard = ({ label, value, change, icon, iconBg }: any) => (
  <div className="bg-white rounded-3xl p-8 border border-slate-100 transition-all duration-300 hover:-translate-y-0.5 cursor-default" style={{ boxShadow: '0 2px 8px rgba(0,0,0,0.06), 0 12px 32px -8px rgba(0,0,0,0.1)' }}>
    <div className={`${iconBg} w-12 h-12 rounded-2xl flex items-center justify-center text-xl mb-5`}>{icon}</div>
    <p className="text-xs font-bold text-slate-400 uppercase tracking-widest mb-1">{label}</p>
    <p className="text-3xl font-black text-slate-900 mb-1">{value}</p>
    <p className="text-xs font-semibold text-emerald-500">{change}</p>
  </div>
);

// ─── Main Component ───────────────────────────────────────────────────────────

export default function App() {
  const [activeTab, setActiveTab] = useState('dashboard');
  const [selectedNodeId, setSelectedNodeId] = useState<number | null>(null);
  const [confirmData, setConfirmData] = useState<{ show: boolean; msg: string; onConfirm: () => void } | null>(null);

  const [restaurants, setRestaurants] = useState<Restaurant[]>([
    {
      id: 1, name: 'KenBoon Restrorant', location: 'Adama Ganda',
      description: 'Legendary local dishes served with love since 2010.',
      image: 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=400',
      status: 'OPEN',
      menu: [
        { id: 101, name: 'Traditional Stew', price: 12.50, category: 'Main' },
        { id: 102, name: 'Special Rice', price: 8.00, category: 'Side' },
      ]
    },
    {
      id: 2, name: 'YegnawBet Restorant', location: 'Adama Posta',
      description: 'Fresh and authentic home-style cooking.',
      image: 'https://images.unsplash.com/photo-1414235077428-338989a2e8c0?w=400',
      status: 'CLOSED',
      menu: [
        { id: 201, name: 'Garden Salad', price: 7.50, category: 'Appetizer' },
      ]
    },
  ]);

  const [form, setForm] = useState({ name: '', location: '', description: '', image: '' });
  const [menuForm, setMenuForm] = useState({ name: '', price: '', category: 'Main' });

  const selectedNode = restaurants.find(r => r.id === selectedNodeId);
  const totalItems = restaurants.reduce((acc, r) => acc + r.menu.length, 0);

  const confirm = (msg: string, onConfirm: () => void) =>
    setConfirmData({ show: true, msg, onConfirm });

  const handleCreateNode = (e: React.FormEvent) => {
    e.preventDefault();
    if (!form.name.trim()) return;
    setRestaurants(prev => [{ id: Date.now(), ...form, status: 'OPEN', menu: [] }, ...prev]);
    setForm({ name: '', location: '', description: '', image: '' });
  };

  const handleDeleteRestaurant = (id: number) =>
    confirm('This will permanently remove this restaurant and all its menu items.', () => {
      setRestaurants(prev => prev.filter(r => r.id !== id));
      if (selectedNodeId === id) setSelectedNodeId(null);
      setConfirmData(null);
    });

  const handleAddMenuItem = (e: React.FormEvent) => {
    e.preventDefault();
    if (!selectedNodeId || !menuForm.name.trim()) return;
    setRestaurants(prev => prev.map(r =>
      r.id === selectedNodeId
        ? { ...r, menu: [...r.menu, { id: Date.now(), name: menuForm.name, price: parseFloat(menuForm.price) || 0, category: menuForm.category }] }
        : r
    ));
    setMenuForm({ name: '', price: '', category: 'Main' });
  };

  const handleDeleteMenuItem = (nodeId: number, itemId: number) =>
    confirm('Remove this item from the restaurant menu?', () => {
      setRestaurants(prev => prev.map(r =>
        r.id === nodeId ? { ...r, menu: r.menu.filter(m => m.id !== itemId) } : r
      ));
      setConfirmData(null);
    });

  // ─── Sidebar Nav Item ─────────────────────────────────────────────────────

  const NavItem = ({ id, label, icon }: { id: string; label: string; icon: string }) => {
    const isActive = activeTab === id && !selectedNodeId;
    return (
      <button
        onClick={() => { setActiveTab(id); setSelectedNodeId(null); }}
        className={`w-full flex items-center gap-3 px-5 py-3.5 rounded-2xl text-sm font-bold transition-all duration-200 mb-1 ${isActive ? 'bg-[#FF5A5F] text-white shadow-lg' : 'text-slate-500 hover:bg-slate-100 hover:text-slate-800'
          }`}
        style={isActive ? { boxShadow: '0 8px 20px -4px rgba(255,90,95,0.4)' } : {}}
      >
        <span className="text-base">{icon}</span>
        <span className="tracking-wide">{label}</span>
      </button>
    );
  };

  // ─── Input Field ──────────────────────────────────────────────────────────

  const Field = ({ label, type = 'text', placeholder, value, onChange }: any) => (
    <div>
      <label className="block text-xs font-bold text-slate-500 uppercase tracking-widest mb-2">{label}</label>
      <input
        type={type}
        className="w-full bg-slate-50 border border-slate-200 px-4 py-3.5 rounded-xl text-sm font-medium text-slate-800 focus:ring-2 focus:ring-[#FF5A5F] focus:border-transparent outline-none transition-all placeholder:text-slate-300"
        placeholder={placeholder}
        value={value}
        onChange={onChange}
      />
    </div>
  );

  // ─── Page Header ──────────────────────────────────────────────────────────

  const PageHeader = ({ title, subtitle }: { title: string; subtitle: string }) => (
    <header className="mb-10">
      <h2 className="text-4xl font-black text-slate-900 leading-tight">{title}</h2>
      <p className="text-slate-400 font-medium mt-1.5">{subtitle}</p>
    </header>
  );

  // ─── Render ───────────────────────────────────────────────────────────────

  return (
    <div className="flex min-h-screen font-sans" style={{ background: '#EEF0F5' }}>
      <ConfirmModal
        show={confirmData?.show}
        message={confirmData?.msg}
        onConfirm={confirmData?.onConfirm}
        onCancel={() => setConfirmData(null)}
      />

      {/* Sidebar */}
      <aside className="w-72 bg-white flex flex-col sticky top-0 h-screen shrink-0" style={{ borderRight: '1px solid #E8EBF0', boxShadow: '4px 0 24px rgba(0,0,0,0.04)' }}>
        {/* Branding */}
        <div className="p-8 pb-6">
          <div className="flex items-center gap-3">
            <div className="w-10 h-10 bg-[#FF5A5F] rounded-xl flex items-center justify-center text-lg" style={{ boxShadow: '0 6px 16px -4px rgba(255,90,95,0.5)' }}>🥘</div>
            <div>
              <h1 className="text-lg font-black text-slate-900">Coral Suite</h1>
              <p className="text-[10px] font-bold text-slate-400 uppercase tracking-widest">Admin Panel</p>
            </div>
          </div>
        </div>

        <div className="px-4 flex-1 space-y-0.5">
          <p className="text-[10px] font-bold text-slate-300 uppercase tracking-widest px-5 py-2">Management</p>
          <NavItem id="dashboard" label="Dashboard" icon="📊" />
          <NavItem id="nodes" label="Restaurants" icon="🏪" />
          <NavItem id="broadcast" label="Broadcasts" icon="📣" />
        </div>

        {/* Footer Badge */}
        <div className="p-6">
          <div className="bg-slate-900 rounded-2xl p-5">
            <div className="flex items-center gap-2 mb-2">
              <div className="w-2 h-2 rounded-full bg-emerald-400 animate-pulse"></div>
              <p className="text-xs font-bold text-emerald-400 uppercase tracking-widest">All Systems Active</p>
            </div>
            <p className="text-white font-black text-sm">{restaurants.length} Nodes Online</p>
          </div>
        </div>
      </aside>

      {/* Main Workspace */}
      <main className="flex-1 p-10 overflow-y-auto">

        {/* ── Dashboard ─────────────────────────────────── */}
        {activeTab === 'dashboard' && !selectedNodeId && (
          <div>
            <PageHeader title="Dashboard" subtitle="Network metrics for your restaurant ecosystem." />

            <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
              <StatCard label="Restaurants" value={restaurants.length} change={`${restaurants.filter(r => r.status === 'OPEN').length} open now`} icon="🏪" iconBg="bg-blue-50" />
              <StatCard label="Menu Items" value={totalItems} change="Across all locations" icon="📋" iconBg="bg-emerald-50" />
              <StatCard label="Growth" value="+12%" change="This month" icon="📈" iconBg="bg-orange-50" />
            </div>

            <div className="bg-slate-900 rounded-3xl p-10 relative overflow-hidden" style={{ boxShadow: '0 20px 48px -8px rgba(0,0,0,0.25)' }}>
              <div className="relative z-10">
                <h3 className="text-3xl font-black text-white mb-3">Add a New Restaurant</h3>
                <p className="text-slate-400 text-base mb-8 max-w-md">Deploy a new location to your customer-facing app. Set its details, menu, and go live instantly.</p>
                <button
                  onClick={() => setActiveTab('nodes')}
                  className="px-8 py-4 rounded-2xl font-black text-base text-white bg-[#FF5A5F] hover:scale-105 active:scale-95 transition-transform"
                  style={{ boxShadow: '0 8px 24px -4px rgba(255,90,95,0.5)' }}
                >
                  Go to Restaurants →
                </button>
              </div>
              <div className="absolute right-0 bottom-0 text-[180px] opacity-5">🍔</div>
            </div>
          </div>
        )}

        {/* ── Restaurants List ───────────────────────────── */}
        {activeTab === 'nodes' && !selectedNodeId && (
          <div>
            <PageHeader title="Restaurants" subtitle="Manage and configure all your food locations." />

            <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
              {/* Add Form */}
              <div className="lg:col-span-1">
                <div className="bg-white rounded-3xl p-8 sticky top-10" style={{ boxShadow: '0 2px 8px rgba(0,0,0,0.06), 0 12px 32px -8px rgba(0,0,0,0.1)', border: '1px solid #E8EBF0' }}>
                  <h3 className="text-lg font-black text-slate-900 mb-1">New Restaurant</h3>
                  <p className="text-xs text-slate-400 font-medium mb-7">Fill in the details and deploy.</p>
                  <form onSubmit={handleCreateNode} className="space-y-5">
                    <Field label="Brand Name" placeholder="e.g. Saffron Luxe" value={form.name} onChange={(e: any) => setForm({ ...form, name: e.target.value })} />
                    <Field label="Location" placeholder="e.g. Adama, Ganda 04" value={form.location} onChange={(e: any) => setForm({ ...form, location: e.target.value })} />
                    <Field label="Photo URL" placeholder="https://..." value={form.image} onChange={(e: any) => setForm({ ...form, image: e.target.value })} />
                    <div>
                      <label className="block text-xs font-bold text-slate-500 uppercase tracking-widest mb-2">Description</label>
                      <textarea
                        className="w-full bg-slate-50 border border-slate-200 px-4 py-3.5 rounded-xl text-sm font-medium text-slate-800 resize-none focus:ring-2 focus:ring-[#FF5A5F] focus:border-transparent outline-none placeholder:text-slate-300"
                        placeholder="What makes it special?"
                        rows={3}
                        value={form.description}
                        onChange={e => setForm({ ...form, description: e.target.value })}
                      />
                    </div>
                    <button className="w-full py-4 rounded-2xl text-white font-black text-sm bg-[#FF5A5F] hover:bg-[#e84d52] active:scale-95 transition-all" style={{ boxShadow: '0 8px 24px -4px rgba(255,90,95,0.35)' }}>
                      Deploy Restaurant →
                    </button>
                  </form>
                </div>
              </div>

              {/* Restaurant Cards */}
              <div className="lg:col-span-2 space-y-4">
                {restaurants.map(r => (
                  <div key={r.id} className="bg-white rounded-3xl p-6 flex gap-5 items-start group transition-all duration-300 hover:shadow-lg" style={{ border: '1px solid #E8EBF0', boxShadow: '0 1px 4px rgba(0,0,0,0.05)' }}>
                    <img src={r.image || 'https://via.placeholder.com/400'} alt={r.name} className="w-24 h-24 rounded-2xl object-cover shrink-0" />
                    <div className="flex-1 min-w-0">
                      <div className="flex items-start justify-between gap-4 mb-1">
                        <h4 className="font-black text-slate-900 text-lg leading-tight">{r.name}</h4>
                        <span className={`shrink-0 text-[10px] font-bold uppercase tracking-widest px-3 py-1 rounded-full ${r.status === 'OPEN' ? 'bg-emerald-50 text-emerald-600' : 'bg-slate-100 text-slate-400'}`}>
                          {r.status}
                        </span>
                      </div>
                      <p className="text-xs text-slate-400 font-medium mb-2">{r.location}</p>
                      <p className="text-sm text-slate-500 mb-4 line-clamp-1">{r.description}</p>
                      <div className="flex items-center gap-3">
                        <button
                          onClick={() => setSelectedNodeId(r.id)}
                          className="px-5 py-2 rounded-xl bg-slate-900 text-white text-xs font-black hover:bg-slate-700 transition-colors"
                        >
                          Edit Menu ({r.menu.length})
                        </button>
                        <button
                          onClick={() => handleDeleteRestaurant(r.id)}
                          className="px-5 py-2 rounded-xl border border-slate-200 text-red-400 text-xs font-black hover:bg-red-50 hover:border-red-200 transition-colors"
                        >
                          Remove
                        </button>
                      </div>
                    </div>
                  </div>
                ))}
              </div>
            </div>
          </div>
        )}

        {/* ── Menu Editor ────────────────────────────────── */}
        {selectedNodeId && selectedNode && (
          <div>
            <button
              onClick={() => setSelectedNodeId(null)}
              className="flex items-center gap-2 text-xs font-bold text-slate-400 hover:text-slate-700 transition-colors mb-8 uppercase tracking-widest"
            >
              ← Back to Restaurants
            </button>

            <div className="flex items-center gap-5 mb-10 bg-white rounded-2xl p-5" style={{ border: '1px solid #E8EBF0', boxShadow: '0 1px 4px rgba(0,0,0,0.05)' }}>
              <img src={selectedNode.image} className="w-16 h-16 rounded-2xl object-cover" alt={selectedNode.name} />
              <div>
                <h2 className="text-2xl font-black text-slate-900">{selectedNode.name} — Menu</h2>
                <p className="text-sm text-slate-400 font-medium">{selectedNode.location} · {selectedNode.menu.length} items</p>
              </div>
            </div>

            <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
              {/* Add Menu Item Form */}
              <div className="lg:col-span-1">
                <div className="bg-white rounded-3xl p-8 sticky top-10" style={{ border: '1px solid #E8EBF0', boxShadow: '0 2px 8px rgba(0,0,0,0.06)' }}>
                  <h3 className="text-lg font-black text-slate-900 mb-1">Add Menu Item</h3>
                  <p className="text-xs text-slate-400 font-medium mb-7">This will appear in the customer app.</p>
                  <form onSubmit={handleAddMenuItem} className="space-y-5">
                    <Field label="Item Name" placeholder="e.g. Chicken Burger" value={menuForm.name} onChange={(e: any) => setMenuForm({ ...menuForm, name: e.target.value })} />
                    <Field label="Price ($)" type="number" placeholder="0.00" value={menuForm.price} onChange={(e: any) => setMenuForm({ ...menuForm, price: e.target.value })} />
                    <div>
                      <label className="block text-xs font-bold text-slate-500 uppercase tracking-widest mb-2">Category</label>
                      <select
                        className="w-full bg-slate-50 border border-slate-200 px-4 py-3.5 rounded-xl text-sm font-medium text-slate-800 focus:ring-2 focus:ring-[#FF5A5F] outline-none"
                        value={menuForm.category}
                        onChange={e => setMenuForm({ ...menuForm, category: e.target.value })}
                      >
                        {['Main', 'Side', 'Drink', 'Dessert', 'Appetizer'].map(c => <option key={c}>{c}</option>)}
                      </select>
                    </div>
                    <button className="w-full py-4 rounded-2xl text-white font-black text-sm bg-[#FF5A5F] hover:bg-[#e84d52] active:scale-95 transition-all" style={{ boxShadow: '0 8px 24px -4px rgba(255,90,95,0.35)' }}>
                      Add to Menu →
                    </button>
                  </form>
                </div>
              </div>

              {/* Menu Items List */}
              <div className="lg:col-span-2 space-y-3">
                {selectedNode.menu.length === 0 ? (
                  <div className="bg-white rounded-3xl p-16 text-center" style={{ border: '2px dashed #E8EBF0' }}>
                    <p className="text-4xl mb-3">🍽️</p>
                    <p className="text-slate-400 font-bold text-sm">No menu items yet</p>
                    <p className="text-slate-300 text-xs mt-1">Add your first item using the form.</p>
                  </div>
                ) : (
                  selectedNode.menu.map(item => (
                    <div key={item.id} className="bg-white rounded-2xl px-6 py-4 flex items-center justify-between group transition-all duration-200 hover:shadow-md" style={{ border: '1px solid #E8EBF0' }}>
                      <div className="flex items-center gap-4">
                        <div className="w-10 h-10 bg-slate-50 rounded-xl flex items-center justify-center text-lg">🍲</div>
                        <div>
                          <p className="font-bold text-slate-800">{item.name}</p>
                          <p className="text-xs text-slate-400 font-medium">{item.category}</p>
                        </div>
                      </div>
                      <div className="flex items-center gap-5">
                        <p className="font-black text-slate-900">${item.price.toFixed(2)}</p>
                        <button
                          onClick={() => handleDeleteMenuItem(selectedNode.id, item.id)}
                          className="text-xs font-bold text-slate-300 hover:text-red-500 transition-colors opacity-0 group-hover:opacity-100"
                        >
                          Remove
                        </button>
                      </div>
                    </div>
                  ))
                )}
              </div>
            </div>
          </div>
        )}

        {/* ── Broadcast ──────────────────────────────────── */}
        {activeTab === 'broadcast' && !selectedNodeId && (
          <div className="max-w-3xl">
            <PageHeader title="Broadcasts" subtitle="Send announcements to all users across your network." />
            <div className="bg-white rounded-3xl p-10" style={{ border: '1px solid #E8EBF0', boxShadow: '0 2px 8px rgba(0,0,0,0.06), 0 12px 32px -8px rgba(0,0,0,0.1)' }}>
              <div className="space-y-6 mb-8">
                <Field label="Title" placeholder="e.g. Flash Sale — 50% off today!" value="" onChange={() => { }} />
                <div>
                  <label className="block text-xs font-bold text-slate-500 uppercase tracking-widest mb-2">Message</label>
                  <textarea
                    className="w-full bg-slate-50 border border-slate-200 px-4 py-3.5 rounded-xl text-sm font-medium text-slate-800 resize-none focus:ring-2 focus:ring-[#FF5A5F] focus:border-transparent outline-none placeholder:text-slate-300"
                    placeholder="Compose your message to all users..."
                    rows={5}
                  />
                </div>
              </div>
              <button
                onClick={() => alert('📡 Broadcast sent to all users!')}
                className="w-full py-4 rounded-2xl text-white font-black text-sm bg-slate-900 hover:bg-slate-800 active:scale-95 transition-all"
              >
                Send to All Users 📢
              </button>
            </div>
          </div>
        )}

      </main>
    </div>
  );
}
