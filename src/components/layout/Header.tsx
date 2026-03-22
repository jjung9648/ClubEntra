import { useEffect, useRef, useState } from 'react';
import { Bell, Search, Menu, Megaphone, Pin, X } from 'lucide-react';
import { supabase } from '../../lib/supabase';
import { useAuth } from '../../context/AuthContext';
import type { Announcement, Page } from '../../lib/types';

const SEEN_KEY = 'clubentra_seen_announcements';

const pageTitles: Record<Page, string> = {
  dashboard: 'Dashboard',
  directory: 'Discover Clubs',
  'club-detail': 'Club',
  'my-clubs': 'My Clubs',
  events: 'Events',
  announcements: 'Announcements',
  documents: 'Documents',
  funding: 'Funding & Budget',
  officer: 'Officer Tools',
  analytics: 'Analytics',
  profile: 'Profile & Settings',
  collaborations: 'Collaborations',
};

interface HeaderProps {
  currentPage: Page;
  onMenuToggle: () => void;
  searchQuery: string;
  onSearchChange: (q: string) => void;
  showSearch?: boolean;
  onNavigate?: (page: Page) => void;
}

type AnnWithClub = Announcement & { clubs?: { name: string } };

function getSeenIds(): Set<string> {
  try {
    const raw = localStorage.getItem(SEEN_KEY);
    return new Set(raw ? JSON.parse(raw) : []);
  } catch {
    return new Set();
  }
}

function markAllSeen(ids: string[]) {
  try {
    localStorage.setItem(SEEN_KEY, JSON.stringify(ids));
  } catch {
    // ignore
  }
}

export function Header({ currentPage, onMenuToggle, searchQuery, onSearchChange, showSearch, onNavigate }: HeaderProps) {
  const { user } = useAuth();
  const [open, setOpen] = useState(false);
  const [announcements, setAnnouncements] = useState<AnnWithClub[]>([]);
  const [loading, setLoading] = useState(false);
  const [seenIds, setSeenIds] = useState<Set<string>>(getSeenIds);
  const dropdownRef = useRef<HTMLDivElement>(null);

  const unreadCount = announcements.filter(a => !seenIds.has(a.id)).length;

  useEffect(() => {
    if (!user) return;
    fetchAnnouncements();
  }, [user]);

  useEffect(() => {
    function handleClick(e: MouseEvent) {
      if (dropdownRef.current && !dropdownRef.current.contains(e.target as Node)) {
        setOpen(false);
      }
    }
    if (open) document.addEventListener('mousedown', handleClick);
    return () => document.removeEventListener('mousedown', handleClick);
  }, [open]);

  async function fetchAnnouncements() {
    if (!user) return;
    setLoading(true);
    const { data } = await supabase
      .from('announcements')
      .select('*, clubs(name)')
      .order('is_pinned', { ascending: false })
      .order('created_at', { ascending: false })
      .limit(10);
    setAnnouncements((data || []) as AnnWithClub[]);
    setLoading(false);
  }

  function handleBellClick() {
    const next = !open;
    setOpen(next);
    if (next && announcements.length > 0) {
      const ids = announcements.map(a => a.id);
      markAllSeen(ids);
      setSeenIds(new Set(ids));
    }
  }

  function handleViewAll() {
    setOpen(false);
    if (onNavigate) onNavigate('announcements');
  }

  return (
    <header className="h-16 bg-white border-b border-slate-200 flex items-center px-4 lg:px-6 gap-4 sticky top-0 z-20">
      <button onClick={onMenuToggle} className="lg:hidden p-2 rounded-lg hover:bg-slate-100 text-slate-600 transition-colors">
        <Menu size={20} />
      </button>

      <h1 className="font-semibold text-slate-900 text-lg flex-1 lg:flex-none">{pageTitles[currentPage]}</h1>

      {showSearch && (
        <div className="flex-1 max-w-md hidden sm:block">
          <div className="relative">
            <Search size={16} className="absolute left-3 top-1/2 -translate-y-1/2 text-slate-400" />
            <input
              value={searchQuery}
              onChange={e => onSearchChange(e.target.value)}
              placeholder="Search..."
              className="w-full pl-9 pr-4 py-2 text-sm bg-slate-50 border border-slate-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-sky-500 focus:border-transparent transition"
            />
          </div>
        </div>
      )}

      <div className="flex items-center gap-2 ml-auto" ref={dropdownRef}>
        <div className="relative">
          <button
            onClick={handleBellClick}
            className="p-2 rounded-xl hover:bg-slate-100 text-slate-500 hover:text-slate-700 transition-colors relative"
          >
            <Bell size={20} />
            {unreadCount > 0 && (
              <span className="absolute top-1 right-1 w-2 h-2 bg-sky-500 rounded-full" />
            )}
          </button>

          {open && (
            <div className="absolute right-0 top-full mt-2 w-80 bg-white rounded-2xl shadow-xl border border-slate-100 overflow-hidden z-50">
              <div className="flex items-center justify-between px-4 py-3 border-b border-slate-100">
                <span className="text-sm font-semibold text-slate-800">Notifications</span>
                <button onClick={() => setOpen(false)} className="p-1 rounded-lg hover:bg-slate-100 text-slate-400 transition-colors">
                  <X size={14} />
                </button>
              </div>

              <div className="max-h-80 overflow-y-auto">
                {loading ? (
                  <div className="p-4 space-y-3">
                    {[...Array(3)].map((_, i) => (
                      <div key={i} className="h-14 bg-slate-100 animate-pulse rounded-xl" />
                    ))}
                  </div>
                ) : announcements.length === 0 ? (
                  <div className="flex flex-col items-center justify-center py-10 px-4 text-center">
                    <Megaphone size={28} className="text-slate-300 mb-2" />
                    <p className="text-sm font-medium text-slate-500">No Notifications</p>
                    <p className="text-xs text-slate-400 mt-0.5">New announcements will appear here</p>
                  </div>
                ) : (
                  <div className="divide-y divide-slate-50">
                    {announcements.map(ann => (
                      <button
                        key={ann.id}
                        onClick={handleViewAll}
                        className="w-full text-left px-4 py-3 hover:bg-slate-50 transition-colors group"
                      >
                        <div className="flex items-start gap-2.5">
                          <div className="w-7 h-7 bg-sky-50 rounded-lg flex items-center justify-center flex-shrink-0 mt-0.5">
                            {ann.is_pinned
                              ? <Pin size={12} className="text-amber-500" />
                              : <Megaphone size={12} className="text-sky-500" />
                            }
                          </div>
                          <div className="flex-1 min-w-0">
                            <div className="flex items-center gap-1.5 flex-wrap">
                              {ann.clubs && (
                                <span className="text-xs text-sky-600 font-medium">{ann.clubs.name}</span>
                              )}
                              {ann.is_pinned && (
                                <span className="text-xs text-amber-500 font-medium">Pinned</span>
                              )}
                            </div>
                            <p className="text-xs font-semibold text-slate-800 leading-snug mt-0.5 truncate">{ann.title}</p>
                            <p className="text-xs text-slate-500 mt-0.5 line-clamp-2 leading-relaxed">{ann.content}</p>
                            <p className="text-xs text-slate-400 mt-1">
                              {new Date(ann.created_at).toLocaleDateString('en-US', { month: 'short', day: 'numeric' })}
                            </p>
                          </div>
                        </div>
                      </button>
                    ))}
                  </div>
                )}
              </div>

              {announcements.length > 0 && (
                <div className="border-t border-slate-100 px-4 py-2.5">
                  <button
                    onClick={handleViewAll}
                    className="text-xs font-semibold text-sky-600 hover:text-sky-700 transition-colors"
                  >
                    View all announcements
                  </button>
                </div>
              )}
            </div>
          )}
        </div>
      </div>
    </header>
  );
}
