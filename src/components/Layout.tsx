import * as React from "react";
import { LayoutDashboard, Table as TableIcon, History, DollarSign, Settings, Menu, X, PlusCircle, Beef, Syringe, User, Droplets } from "lucide-react";
import { cn } from "@/lib/utils";
import { Button } from "@/components/ui/button";
import { ScrollArea } from "@/components/ui/scroll-area";
import { Sheet, SheetContent, SheetTrigger } from "@/components/ui/sheet";
import { motion, AnimatePresence } from "motion/react";
import { UserSettings } from "@/types";

interface LayoutProps {
  children: React.ReactNode;
  activeTab: string;
  onTabChange: (tab: string) => void;
  settings?: UserSettings;
  onSettingsUpdate?: (s: UserSettings) => void;
  isSaving?: boolean;
  onExit?: () => void;
  dbStatus?: 'loading' | 'connected' | 'error';
  animalCount?: number;
  milkCount?: number;
}

const sidebarItems = [
  { id: "dashboard", label: "Painel", icon: LayoutDashboard },
  { id: "rebanho", label: "Rebanho Ativo", icon: TableIcon },
  { id: "bezerros", label: "Bezerros / Crias", icon: PlusCircle },
  { id: "controle_sanitario", label: "Controle Sanitário", icon: Syringe },
  { id: "engorda", label: "Engorda / Custos", icon: Beef },
  { id: "financeiro", label: "Financeiro", icon: DollarSign },
  { id: "historico", label: "Histórico / Lucro", icon: History },
  { id: "producao_leite", label: "Produção de Leite", icon: Droplets },
  { id: "config", label: "Configurações", icon: Settings },
];

export function Layout({ children, activeTab, onTabChange, settings, isSaving, onExit, dbStatus, animalCount, milkCount }: LayoutProps) {
  const [isMobileMenuOpen, setIsMobileMenuOpen] = React.useState(false);

  const SidebarContent = () => (
    <div className="flex flex-col h-full bg-slate-900 text-slate-100">
      <div className="p-6 flex flex-col gap-1">
        <div className="flex items-center gap-3">
          <div className="w-10 h-10 bg-emerald-500 rounded-xl flex items-center justify-center shadow-lg shadow-emerald-500/20 overflow-hidden">
            <img 
              src="https://images.unsplash.com/photo-1596733430284-f7437764b1a9?q=80&w=200&auto=format&fit=crop" 
              alt="Touro Nelore" 
              className="w-full h-full object-cover"
              referrerPolicy="no-referrer"
            />
          </div>
          <h1 className="text-xl font-bold tracking-tight">AgropecFuturo Leite</h1>
        </div>
        <div className="flex items-center gap-2 mt-2 px-1">
          {settings?.nomePropriedade && (
            <p className="text-[10px] text-emerald-400 font-bold uppercase tracking-widest truncate flex-1">
              {settings.nomePropriedade}
            </p>
          )}
          {isSaving && (
            <div className="flex items-center gap-1.5 animate-pulse">
              <div className="w-1.5 h-1.5 bg-blue-400 rounded-full" />
              <span className="text-[8px] text-blue-400 font-bold uppercase">Salvando...</span>
            </div>
          )}
          {!isSaving && dbStatus === 'connected' && (
            <div className="flex flex-col gap-1">
              <div className="flex items-center gap-1.5">
                <div className="w-1.5 h-1.5 bg-emerald-500 rounded-full shadow-[0_0_8px_rgba(16,185,129,0.5)]" />
                <span className="text-[8px] text-slate-500 font-bold uppercase">Banco de Dados Ativo</span>
              </div>
              <div className="flex flex-col gap-0.5 ml-3">
                <span className="text-[7px] text-slate-400 uppercase tracking-tighter">Registros no HD:</span>
                <span className="text-[8px] text-emerald-400 font-mono font-bold">{animalCount || 0} Animais</span>
                <span className="text-[8px] text-blue-400 font-mono font-bold">{milkCount || 0} Prod. Leite</span>
              </div>
            </div>
          )}
          {dbStatus === 'error' && (
            <div className="flex items-center gap-1.5">
              <div className="w-1.5 h-1.5 bg-red-500 rounded-full" />
              <span className="text-[8px] text-red-500 font-bold uppercase underline">Erro na Memória</span>
            </div>
          )}
        </div>
      </div>
      
      <ScrollArea className="flex-1 px-4">
        <nav className="space-y-2 py-4">
          {sidebarItems.map((item) => (
            <button
              key={item.id}
              onClick={() => {
                onTabChange(item.id);
                setIsMobileMenuOpen(false);
              }}
              className={cn(
                "w-full flex items-center gap-3 px-4 py-3 rounded-lg transition-all duration-200 group",
                activeTab === item.id 
                  ? "bg-emerald-500 text-white shadow-lg shadow-emerald-500/20" 
                  : "text-slate-400 hover:bg-slate-800 hover:text-slate-100"
              )}
            >
              <item.icon className={cn(
                "w-5 h-5 transition-transform duration-200 group-hover:scale-110",
                activeTab === item.id ? "text-white" : "text-slate-400 group-hover:text-slate-100"
              )} />
              <span className="font-medium">{item.label}</span>
            </button>
          ))}
        </nav>
      </ScrollArea>

      <div className="p-4 border-t border-slate-800 space-y-4">
        {/* Decorative Image */}
        <div className="w-full h-24 rounded-xl overflow-hidden border border-slate-700/50 shadow-inner group">
          <img 
            src="/assets/sidebar-photo.png" 
            alt="Bois no pasto" 
            className="w-full h-full object-cover transition-transform duration-700 group-hover:scale-110"
          />
        </div>

        <div className="bg-slate-800/50 rounded-xl p-4 flex items-center gap-3">
          <div className="w-8 h-8 rounded-full bg-emerald-600 flex items-center justify-center text-xs font-bold text-white">
            {settings?.nomeUsuario?.[0]?.toUpperCase() || <User className="w-4 h-4" />}
          </div>
          <div className="flex-1 min-w-0">
            <p className="text-sm font-medium truncate">{settings?.nomeUsuario || 'Configurar Usuário'}</p>
            <p className="text-[10px] text-slate-500 truncate uppercase">{settings?.cartaoProdutor ? `Produtor: ${settings.cartaoProdutor}` : 'N/C'}</p>
          </div>
        </div>
        <div className="px-2 pb-2 flex flex-col gap-2">
          <Button 
            variant="ghost" 
            onClick={onExit}
            className="w-full text-emerald-400 hover:text-emerald-300 hover:bg-emerald-500/10 gap-2 h-8 text-[10px] font-bold uppercase tracking-widest"
          >
            💾 Salvar no Disco
          </Button>
          <p className="text-[9px] text-slate-500 font-medium uppercase tracking-widest text-center">
            Desenvolvido por <span className="text-emerald-500/80 font-bold">Charlton Andrade</span>
          </p>
        </div>
      </div>
    </div>
  );

  return (
    <div className="flex h-screen bg-slate-50 overflow-hidden">
      {/* Desktop Sidebar */}
      <aside className="hidden md:flex w-64 flex-col">
        <SidebarContent />
      </aside>

      {/* Mobile Menu */}
      <div className="md:hidden fixed top-4 left-4 z-50">
        <Sheet open={isMobileMenuOpen} onOpenChange={setIsMobileMenuOpen}>
          <SheetTrigger asChild>
            <Button variant="outline" size="icon" className="bg-white shadow-md">
              <Menu className="w-5 h-5" />
            </Button>
          </SheetTrigger>
          <SheetContent side="left" className="p-0 w-64 border-none">
            <SidebarContent />
          </SheetContent>
        </Sheet>
      </div>

      {/* Main Content */}
      <main className="flex-1 relative overflow-y-auto">
        <div className="max-w-7xl mx-auto p-4 md:p-8">
          <AnimatePresence mode="wait">
            <motion.div
              key={activeTab}
              initial={{ opacity: 0, y: 10 }}
              animate={{ opacity: 1, y: 0 }}
              exit={{ opacity: 0, y: -10 }}
              transition={{ duration: 0.2 }}
            >
              {children}
            </motion.div>
          </AnimatePresence>
        </div>
      </main>
    </div>
  );
}
