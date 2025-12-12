-- ============================================
-- LEAD GENIUS ADMIN - SUPABASE MIGRATIONS
-- Schema inicial com DDL e Row Level Security
-- ============================================

-- ============================================
-- EXTENSÕES
-- ============================================
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================
-- TABELA: tenants
-- Organizações/clientes do sistema
-- ============================================
CREATE TABLE IF NOT EXISTS public.tenants (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    plan VARCHAR(50) DEFAULT 'free' CHECK (plan IN ('free', 'starter', 'professional', 'enterprise')),
    is_active BOOLEAN DEFAULT true,
    owner_user_id UUID NOT NULL,
    settings JSONB DEFAULT '{}',
    max_users INTEGER DEFAULT 1,
    plan_expires_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    metadata JSONB
);

-- Índices
CREATE INDEX idx_tenants_owner ON public.tenants(owner_user_id);
CREATE INDEX idx_tenants_plan ON public.tenants(plan);
CREATE INDEX idx_tenants_active ON public.tenants(is_active);

-- ============================================
-- TABELA: users
-- Usuários do sistema
-- ============================================
CREATE TABLE IF NOT EXISTS public.users (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email VARCHAR(255) NOT NULL UNIQUE,
    name VARCHAR(255) NOT NULL,
    role VARCHAR(50) NOT NULL CHECK (role IN ('owner_admin', 'owner_viewer', 'cliente_admin', 'cliente_user')),
    tenant_id UUID REFERENCES public.tenants(id) ON DELETE SET NULL,
    avatar_url TEXT,
    phone VARCHAR(50),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    last_login TIMESTAMPTZ,
    metadata JSONB
);

-- Índices
CREATE INDEX idx_users_tenant ON public.users(tenant_id);
CREATE INDEX idx_users_role ON public.users(role);
CREATE INDEX idx_users_email ON public.users(email);

-- ============================================
-- TABELA: products
-- Produtos por tenant
-- ============================================
CREATE TABLE IF NOT EXISTS public.products (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id UUID NOT NULL REFERENCES public.tenants(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    price DECIMAL(12,2) NOT NULL DEFAULT 0,
    sale_price DECIMAL(12,2),
    stock INTEGER DEFAULT 0,
    sku VARCHAR(100),
    category VARCHAR(100),
    image_url TEXT,
    is_active BOOLEAN DEFAULT true,
    created_by UUID REFERENCES public.users(id),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    metadata JSONB
);

-- Índices
CREATE INDEX idx_products_tenant ON public.products(tenant_id);
CREATE INDEX idx_products_category ON public.products(category);
CREATE INDEX idx_products_active ON public.products(is_active);

-- ============================================
-- TABELA: services
-- Serviços por tenant
-- ============================================
CREATE TABLE IF NOT EXISTS public.services (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id UUID NOT NULL REFERENCES public.tenants(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    price DECIMAL(12,2) NOT NULL DEFAULT 0,
    billing_type VARCHAR(50) DEFAULT 'projeto' CHECK (billing_type IN ('hora', 'projeto', 'mensal', 'anual')),
    estimated_hours DECIMAL(10,2),
    category VARCHAR(100),
    image_url TEXT,
    is_active BOOLEAN DEFAULT true,
    created_by UUID REFERENCES public.users(id),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    metadata JSONB
);

-- Índices
CREATE INDEX idx_services_tenant ON public.services(tenant_id);
CREATE INDEX idx_services_category ON public.services(category);

-- ============================================
-- TABELA: leads
-- Leads de vendas por tenant
-- ============================================
CREATE TABLE IF NOT EXISTS public.leads (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id UUID NOT NULL REFERENCES public.tenants(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255),
    phone VARCHAR(50),
    company VARCHAR(255),
    position VARCHAR(255),
    source VARCHAR(100),
    status VARCHAR(50) DEFAULT 'novo' CHECK (status IN ('novo', 'contatado', 'qualificado', 'proposta', 'negociacao', 'ganho', 'perdido')),
    estimated_value DECIMAL(12,2),
    notes TEXT,
    tags TEXT[],
    owner_user_id UUID NOT NULL REFERENCES public.users(id),
    expected_close_date DATE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    metadata JSONB
);

-- Índices
CREATE INDEX idx_leads_tenant ON public.leads(tenant_id);
CREATE INDEX idx_leads_status ON public.leads(status);
CREATE INDEX idx_leads_owner ON public.leads(owner_user_id);
CREATE INDEX idx_leads_created ON public.leads(created_at);

-- ============================================
-- TABELA: lead_events
-- Histórico de eventos dos leads
-- ============================================
CREATE TABLE IF NOT EXISTS public.lead_events (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    lead_id UUID NOT NULL REFERENCES public.leads(id) ON DELETE CASCADE,
    type VARCHAR(50) NOT NULL CHECK (type IN ('status_change', 'note', 'call', 'email', 'meeting')),
    description TEXT NOT NULL,
    old_value TEXT,
    new_value TEXT,
    created_by UUID REFERENCES public.users(id),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Índices
CREATE INDEX idx_lead_events_lead ON public.lead_events(lead_id);
CREATE INDEX idx_lead_events_type ON public.lead_events(type);

-- ============================================
-- TABELA: contracts
-- Contratos por tenant
-- ============================================
CREATE TABLE IF NOT EXISTS public.contracts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id UUID NOT NULL REFERENCES public.tenants(id) ON DELETE CASCADE,
    contract_number VARCHAR(100),
    customer_name VARCHAR(255) NOT NULL,
    customer_email VARCHAR(255),
    customer_phone VARCHAR(50),
    customer_document VARCHAR(50),
    customer_address TEXT,
    lead_id UUID REFERENCES public.leads(id) ON DELETE SET NULL,
    items JSONB DEFAULT '[]',
    value DECIMAL(12,2) NOT NULL DEFAULT 0,
    discount DECIMAL(12,2) DEFAULT 0,
    final_value DECIMAL(12,2) NOT NULL DEFAULT 0,
    installments INTEGER DEFAULT 1,
    status VARCHAR(50) DEFAULT 'rascunho' CHECK (status IN ('rascunho', 'enviado', 'assinado', 'ativo', 'finalizado', 'cancelado')),
    start_date DATE NOT NULL,
    end_date DATE,
    notes TEXT,
    terms TEXT,
    pdf_url TEXT,
    signed_at TIMESTAMPTZ,
    created_by UUID REFERENCES public.users(id),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    metadata JSONB
);

-- Índices
CREATE INDEX idx_contracts_tenant ON public.contracts(tenant_id);
CREATE INDEX idx_contracts_status ON public.contracts(status);
CREATE INDEX idx_contracts_lead ON public.contracts(lead_id);

-- ============================================
-- TABELA: invoices
-- Faturas por tenant
-- ============================================
CREATE TABLE IF NOT EXISTS public.invoices (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id UUID NOT NULL REFERENCES public.tenants(id) ON DELETE CASCADE,
    invoice_number VARCHAR(100) NOT NULL,
    period_start DATE NOT NULL,
    period_end DATE NOT NULL,
    items JSONB DEFAULT '[]',
    subtotal DECIMAL(12,2) NOT NULL DEFAULT 0,
    taxes DECIMAL(12,2) DEFAULT 0,
    discount DECIMAL(12,2) DEFAULT 0,
    total DECIMAL(12,2) NOT NULL DEFAULT 0,
    status VARCHAR(50) DEFAULT 'draft' CHECK (status IN ('draft', 'sent', 'paid', 'overdue', 'cancelled')),
    due_date DATE NOT NULL,
    paid_at TIMESTAMPTZ,
    payment_method VARCHAR(100),
    payment_transaction_id VARCHAR(255),
    pdf_url TEXT,
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    metadata JSONB
);

-- Índices
CREATE INDEX idx_invoices_tenant ON public.invoices(tenant_id);
CREATE INDEX idx_invoices_status ON public.invoices(status);
CREATE INDEX idx_invoices_due ON public.invoices(due_date);

-- ============================================
-- TABELA: audit_logs
-- Logs de auditoria
-- ============================================
CREATE TABLE IF NOT EXISTS public.audit_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES public.users(id),
    user_name VARCHAR(255),
    tenant_id UUID REFERENCES public.tenants(id) ON DELETE SET NULL,
    action VARCHAR(50) NOT NULL CHECK (action IN ('create', 'update', 'delete', 'login', 'logout', 'export', 'import')),
    model VARCHAR(100) NOT NULL,
    model_id UUID,
    old_value JSONB,
    new_value JSONB,
    description TEXT,
    ip_address VARCHAR(45),
    user_agent TEXT,
    timestamp TIMESTAMPTZ DEFAULT NOW(),
    metadata JSONB
);

-- Índices
CREATE INDEX idx_audit_user ON public.audit_logs(user_id);
CREATE INDEX idx_audit_tenant ON public.audit_logs(tenant_id);
CREATE INDEX idx_audit_action ON public.audit_logs(action);
CREATE INDEX idx_audit_model ON public.audit_logs(model);
CREATE INDEX idx_audit_timestamp ON public.audit_logs(timestamp);

-- ============================================
-- ROW LEVEL SECURITY (RLS)
-- ============================================

-- Habilita RLS em todas as tabelas
ALTER TABLE public.tenants ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.products ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.services ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.leads ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.lead_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.contracts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.invoices ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.audit_logs ENABLE ROW LEVEL SECURITY;

-- ============================================
-- POLICIES: tenants
-- ============================================

-- Owners podem ver todos os tenants
CREATE POLICY "Owners can view all tenants"
    ON public.tenants FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM public.users u
            WHERE u.id = auth.uid()
            AND u.role LIKE 'owner_%'
        )
    );

-- Owners admins podem criar/editar tenants
CREATE POLICY "Owner admins can manage tenants"
    ON public.tenants FOR ALL
    USING (
        EXISTS (
            SELECT 1 FROM public.users u
            WHERE u.id = auth.uid()
            AND u.role = 'owner_admin'
        )
    );

-- Clientes podem ver apenas seu próprio tenant
CREATE POLICY "Clients can view own tenant"
    ON public.tenants FOR SELECT
    USING (
        id IN (
            SELECT u.tenant_id FROM public.users u
            WHERE u.id = auth.uid()
        )
    );

-- ============================================
-- POLICIES: users
-- ============================================

-- Owners podem ver todos os usuários
CREATE POLICY "Owners can view all users"
    ON public.users FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM public.users u
            WHERE u.id = auth.uid()
            AND u.role LIKE 'owner_%'
        )
    );

-- Usuários podem ver usuários do mesmo tenant
CREATE POLICY "Users can view same tenant users"
    ON public.users FOR SELECT
    USING (
        tenant_id IN (
            SELECT u.tenant_id FROM public.users u
            WHERE u.id = auth.uid()
        )
    );

-- Usuários podem ver/editar próprio perfil
CREATE POLICY "Users can manage own profile"
    ON public.users FOR ALL
    USING (id = auth.uid());

-- ============================================
-- POLICIES: products
-- ============================================

-- Clientes veem apenas produtos do próprio tenant
CREATE POLICY "Clients can view own products"
    ON public.products FOR SELECT
    USING (
        tenant_id IN (
            SELECT u.tenant_id FROM public.users u
            WHERE u.id = auth.uid()
        )
    );

-- Cliente admin pode gerenciar produtos
CREATE POLICY "Client admins can manage products"
    ON public.products FOR ALL
    USING (
        tenant_id IN (
            SELECT u.tenant_id FROM public.users u
            WHERE u.id = auth.uid()
            AND u.role = 'cliente_admin'
        )
    );

-- Owners podem ver todos os produtos
CREATE POLICY "Owners can view all products"
    ON public.products FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM public.users u
            WHERE u.id = auth.uid()
            AND u.role LIKE 'owner_%'
        )
    );

-- ============================================
-- POLICIES: services (mesma lógica de products)
-- ============================================

CREATE POLICY "Clients can view own services"
    ON public.services FOR SELECT
    USING (
        tenant_id IN (
            SELECT u.tenant_id FROM public.users u
            WHERE u.id = auth.uid()
        )
    );

CREATE POLICY "Client admins can manage services"
    ON public.services FOR ALL
    USING (
        tenant_id IN (
            SELECT u.tenant_id FROM public.users u
            WHERE u.id = auth.uid()
            AND u.role = 'cliente_admin'
        )
    );

CREATE POLICY "Owners can view all services"
    ON public.services FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM public.users u
            WHERE u.id = auth.uid()
            AND u.role LIKE 'owner_%'
        )
    );

-- ============================================
-- POLICIES: leads
-- ============================================

CREATE POLICY "Clients can view own leads"
    ON public.leads FOR SELECT
    USING (
        tenant_id IN (
            SELECT u.tenant_id FROM public.users u
            WHERE u.id = auth.uid()
        )
    );

CREATE POLICY "Client admins can manage leads"
    ON public.leads FOR ALL
    USING (
        tenant_id IN (
            SELECT u.tenant_id FROM public.users u
            WHERE u.id = auth.uid()
            AND u.role IN ('cliente_admin', 'cliente_user')
        )
    );

CREATE POLICY "Owners can view all leads"
    ON public.leads FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM public.users u
            WHERE u.id = auth.uid()
            AND u.role LIKE 'owner_%'
        )
    );

-- ============================================
-- POLICIES: lead_events
-- ============================================

CREATE POLICY "Clients can view own lead events"
    ON public.lead_events FOR SELECT
    USING (
        lead_id IN (
            SELECT l.id FROM public.leads l
            JOIN public.users u ON l.tenant_id = u.tenant_id
            WHERE u.id = auth.uid()
        )
    );

CREATE POLICY "Clients can create lead events"
    ON public.lead_events FOR INSERT
    WITH CHECK (
        lead_id IN (
            SELECT l.id FROM public.leads l
            JOIN public.users u ON l.tenant_id = u.tenant_id
            WHERE u.id = auth.uid()
        )
    );

-- ============================================
-- POLICIES: contracts
-- ============================================

CREATE POLICY "Clients can view own contracts"
    ON public.contracts FOR SELECT
    USING (
        tenant_id IN (
            SELECT u.tenant_id FROM public.users u
            WHERE u.id = auth.uid()
        )
    );

CREATE POLICY "Client admins can manage contracts"
    ON public.contracts FOR ALL
    USING (
        tenant_id IN (
            SELECT u.tenant_id FROM public.users u
            WHERE u.id = auth.uid()
            AND u.role = 'cliente_admin'
        )
    );

CREATE POLICY "Owners can view all contracts"
    ON public.contracts FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM public.users u
            WHERE u.id = auth.uid()
            AND u.role LIKE 'owner_%'
        )
    );

-- ============================================
-- POLICIES: invoices
-- ============================================

CREATE POLICY "Clients can view own invoices"
    ON public.invoices FOR SELECT
    USING (
        tenant_id IN (
            SELECT u.tenant_id FROM public.users u
            WHERE u.id = auth.uid()
        )
    );

CREATE POLICY "Owners can manage all invoices"
    ON public.invoices FOR ALL
    USING (
        EXISTS (
            SELECT 1 FROM public.users u
            WHERE u.id = auth.uid()
            AND u.role = 'owner_admin'
        )
    );

-- ============================================
-- POLICIES: audit_logs
-- ============================================

CREATE POLICY "Users can create audit logs"
    ON public.audit_logs FOR INSERT
    WITH CHECK (user_id = auth.uid());

CREATE POLICY "Owners can view all audit logs"
    ON public.audit_logs FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM public.users u
            WHERE u.id = auth.uid()
            AND u.role LIKE 'owner_%'
        )
    );

CREATE POLICY "Client admins can view tenant audit logs"
    ON public.audit_logs FOR SELECT
    USING (
        tenant_id IN (
            SELECT u.tenant_id FROM public.users u
            WHERE u.id = auth.uid()
            AND u.role = 'cliente_admin'
        )
    );

-- ============================================
-- SEED DATA - Dados de exemplo
-- ============================================

-- Nota: Execute estes inserts APÓS criar um usuário via auth.signUp()
-- e substituir os IDs abaixo pelos IDs reais

/*
-- 1. Criar usuário owner no Supabase Auth primeiro
-- Depois inserir na tabela users:

INSERT INTO public.users (id, email, name, role, is_active)
VALUES (
    'SEU-USER-ID-AQUI', -- ID do usuário criado no Auth
    'admin@leadgenius.com',
    'Super Admin',
    'owner_admin',
    true
);

-- 2. Criar tenant de exemplo

INSERT INTO public.tenants (name, plan, is_active, owner_user_id, max_users)
VALUES (
    'Empresa Exemplo',
    'professional',
    true,
    'SEU-USER-ID-DO-CLIENTE-ADMIN',
    20
) RETURNING id;

-- 3. Criar usuário cliente admin

INSERT INTO public.users (id, email, name, role, tenant_id, is_active)
VALUES (
    'ID-DO-USUARIO-CLIENTE',
    'cliente@empresa.com',
    'Admin da Empresa',
    'cliente_admin',
    'ID-DO-TENANT-CRIADO',
    true
);

-- 4. Criar leads de exemplo

INSERT INTO public.leads (tenant_id, name, email, phone, company, status, estimated_value, owner_user_id)
VALUES
    ('ID-TENANT', 'João Silva', 'joao@email.com', '11999999999', 'Tech Corp', 'novo', 5000, 'ID-USUARIO'),
    ('ID-TENANT', 'Maria Santos', 'maria@email.com', '11988888888', 'Digital SA', 'contatado', 10000, 'ID-USUARIO'),
    ('ID-TENANT', 'Pedro Oliveira', 'pedro@email.com', '11977777777', 'StartupXYZ', 'qualificado', 25000, 'ID-USUARIO');

-- 5. Criar produtos de exemplo

INSERT INTO public.products (tenant_id, name, description, price, stock, created_by)
VALUES
    ('ID-TENANT', 'Produto A', 'Descrição do produto A', 199.90, 100, 'ID-USUARIO'),
    ('ID-TENANT', 'Produto B', 'Descrição do produto B', 299.90, 50, 'ID-USUARIO'),
    ('ID-TENANT', 'Produto C', 'Descrição do produto C', 499.90, 25, 'ID-USUARIO');

*/

-- ============================================
-- FUNÇÃO: Trigger para atualizar updated_at
-- ============================================

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Aplica trigger em todas as tabelas relevantes
CREATE TRIGGER update_tenants_updated_at BEFORE UPDATE ON public.tenants FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON public.users FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_products_updated_at BEFORE UPDATE ON public.products FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_services_updated_at BEFORE UPDATE ON public.services FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_leads_updated_at BEFORE UPDATE ON public.leads FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_contracts_updated_at BEFORE UPDATE ON public.contracts FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_invoices_updated_at BEFORE UPDATE ON public.invoices FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ============================================
-- FIM DO SCRIPT
-- ============================================
