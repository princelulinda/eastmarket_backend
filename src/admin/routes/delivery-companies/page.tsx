import { defineRouteConfig } from "@medusajs/admin-sdk";
import { useEffect, useState } from "react";

// Configuration de la route
export const config = defineRouteConfig({
  label: "Delivery Companies",
});

export default function DeliveryCompaniesPage() {
  const [companies, setCompanies] = useState<any[]>([]);
  const [shippingOptions, setShippingOptions] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [submitting, setSubmitting] = useState(false);
  const [deletingId, setDeletingId] = useState<string | null>(null);
  
  const [name, setName] = useState("");
  const [email, setEmail] = useState("");
  const [phone, setPhone] = useState("");
  const [selectedShippingOptions, setSelectedShippingOptions] = useState<string[]>([]);

  const fetchData = async (method: "GET" | "POST" | "DELETE", url: string, body?: any) => {
    try {
      const options: RequestInit = {
        method,
        headers: {
          "Content-Type": "application/json",
        },
        credentials: "include", 
      };
      if (body) {
        options.body = JSON.stringify(body);
      }

      const response = await fetch(url, options);
      
      if (response.status === 401) {
        throw new Error("Session expirée. Veuillez vous reconnecter.");
      }
      
      if (!response.ok) {
        const errorData = await response.json();
        throw new Error(errorData.message || "Erreur lors de la requête");
      }
      
      return await response.json();
    } catch (err) {
      console.error("Erreur:", err);
      alert(err instanceof Error ? err.message : "Une erreur est survenue");
    }
  };

  const fetchCompanies = async () => {
    setLoading(true);
    const data = await fetchData("GET", "/admin/delivery-companies");
    if (data) setCompanies(data.delivery_companies);
    setLoading(false);
  };

  const fetchShippingOptions = async () => {
    const data = await fetchData("GET", "/admin/shipping-options");
    if (data) setShippingOptions(data.shipping_options);
  };

  useEffect(() => {
    fetchCompanies();
    fetchShippingOptions();
  }, []);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setSubmitting(true);
    const data = await fetchData("POST", "/admin/delivery-companies", { 
        name, email, phone, 
        is_active: true,
        shipping_option_ids: selectedShippingOptions
    });
    setSubmitting(false);
    if (data) {
      setName("");
      setEmail("");
      setPhone("");
      setSelectedShippingOptions([]);
      fetchCompanies();
    }
  };

  const handleDelete = async (companyId: string, companyName: string) => {
    if (!confirm(`Êtes-vous sûr de vouloir supprimer l'entreprise "${companyName}" ?`)) {
      return;
    }
    setDeletingId(companyId);
    const data = await fetchData("DELETE", `/admin/delivery-companies/${companyId}`);
    setDeletingId(null);
    if (data) {
      fetchCompanies();
    }
  };

  return (
    <div className="admin-page-container">
      {/* Styles injectés pour conserver un seul fichier propre avec de riches effets et transitions */}
      <style>{`
        .admin-page-container {
          padding: 2rem;
          font-family: 'Inter', -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
          color: #1f2937;
          background-color: #f9fafb;
          min-height: 100vh;
        }
        .page-header {
          margin-bottom: 2rem;
          border-bottom: 1px solid #e5e7eb;
          padding-bottom: 1rem;
        }
        .page-title {
          font-size: 1.875rem;
          font-weight: 700;
          color: #111827;
          letter-spacing: -0.025em;
          margin: 0;
        }
        .page-subtitle {
          font-size: 0.875rem;
          color: #6b7280;
          margin-top: 0.25rem;
        }
        .grid-layout {
          display: grid;
          grid-template-columns: 1fr;
          gap: 2rem;
        }
        @media(min-width: 1024px) {
          .grid-layout {
            grid-template-columns: 350px 1fr;
          }
        }
        .card {
          background-color: #ffffff;
          border-radius: 12px;
          border: 1px solid #e5e7eb;
          box-shadow: 0 1px 3px 0 rgba(0, 0, 0, 0.05), 0 1px 2px 0 rgba(0, 0, 0, 0.03);
          padding: 1.5rem;
          transition: transform 0.2s, box-shadow 0.2s;
        }
        .card:hover {
          box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.05), 0 2px 4px -1px rgba(0, 0, 0, 0.03);
        }
        .card-title {
          font-size: 1.25rem;
          font-weight: 600;
          color: #111827;
          margin-top: 0;
          margin-bottom: 1.25rem;
        }
        .form-group {
          margin-bottom: 1.25rem;
          display: flex;
          flex-direction: column;
          gap: 0.375rem;
        }
        .form-label {
          font-size: 0.875rem;
          font-weight: 500;
          color: #374151;
        }
        .form-input {
          padding: 0.625rem 0.875rem;
          font-size: 0.875rem;
          border: 1px solid #d1d5db;
          border-radius: 8px;
          background-color: #ffffff;
          transition: border-color 0.15s, box-shadow 0.15s;
          width: 100%;
          box-sizing: border-box;
        }
        .form-input:focus {
          outline: 2px solid transparent;
          border-color: #4f46e5;
          box-shadow: 0 0 0 3px rgba(79, 70, 229, 0.1);
        }
        .form-select-multiple {
          height: 120px;
          font-family: inherit;
        }
        .btn-primary {
          background-color: #4f46e5;
          color: #ffffff;
          font-weight: 600;
          font-size: 0.875rem;
          padding: 0.625rem 1.25rem;
          border-radius: 8px;
          border: 1px solid transparent;
          cursor: pointer;
          transition: background-color 0.15s, transform 0.1s;
          display: flex;
          align-items: center;
          justify-content: center;
          width: 100%;
        }
        .btn-primary:hover:not(:disabled) {
          background-color: #4338ca;
        }
        .btn-primary:active:not(:disabled) {
          transform: translateY(1px);
        }
        .btn-primary:disabled {
          opacity: 0.6;
          cursor: not-allowed;
        }
        .table-container {
          overflow-x: auto;
        }
        .admin-table {
          width: 100%;
          border-collapse: collapse;
          text-align: left;
          font-size: 0.875rem;
        }
        .admin-table th {
          background-color: #f3f4f6;
          padding: 0.75rem 1rem;
          font-weight: 600;
          color: #4b5563;
          border-bottom: 1px solid #e5e7eb;
        }
        .admin-table td {
          padding: 1rem;
          border-bottom: 1px solid #f3f4f6;
          vertical-align: middle;
        }
        .admin-table tr:hover td {
          background-color: #f9fafb;
        }
        .badge {
          display: inline-flex;
          align-items: center;
          padding: 0.125rem 0.625rem;
          border-radius: 9999px;
          font-size: 0.75rem;
          font-weight: 500;
        }
        .badge-active {
          background-color: #d1fae5;
          color: #065f46;
        }
        .badge-inactive {
          background-color: #fee2e2;
          color: #991b1b;
        }
        .btn-delete {
          background-color: transparent;
          color: #ef4444;
          border: 1px solid #fca5a5;
          padding: 0.375rem 0.75rem;
          border-radius: 6px;
          font-size: 0.75rem;
          font-weight: 500;
          cursor: pointer;
          transition: background-color 0.15s, color 0.15s;
          display: inline-flex;
          align-items: center;
          gap: 0.25rem;
        }
        .btn-delete:hover:not(:disabled) {
          background-color: #fee2e2;
          color: #b91c1c;
          border-color: #f87171;
        }
        .btn-delete:disabled {
          opacity: 0.5;
          cursor: not-allowed;
        }
        .empty-state {
          text-align: center;
          padding: 3rem 1.5rem;
          color: #6b7280;
        }
        .empty-state-icon {
          font-size: 2.5rem;
          margin-bottom: 1rem;
          color: #9ca3af;
        }
        .empty-state-text {
          font-size: 0.875rem;
          margin: 0;
        }
      `}</style>

      <div className="page-header">
        <h1 className="page-title">Entreprises de Livraison</h1>
        <p className="page-subtitle">Gérez les compagnies de livraison partenaires et leurs options d'expédition.</p>
      </div>
      
      <div className="grid-layout">
        {/* Panneau de création */}
        <div className="card">
          <h2 className="card-title">Ajouter une entreprise</h2>
          <form onSubmit={handleSubmit}>
            <div className="form-group">
              <label className="form-label">Nom de l'entreprise *</label>
              <input 
                className="form-input" 
                type="text" 
                placeholder="Ex. DHL Express" 
                value={name} 
                onChange={(e) => setName(e.target.value)} 
                required 
              />
            </div>

            <div className="form-group">
              <label className="form-label">Adresse email *</label>
              <input 
                className="form-input" 
                type="email" 
                placeholder="Ex. contact@dhl.com" 
                value={email} 
                onChange={(e) => setEmail(e.target.value)} 
                required 
              />
            </div>

            <div className="form-group">
              <label className="form-label">Numéro de téléphone</label>
              <input 
                className="form-input" 
                type="text" 
                placeholder="Ex. +33 1 23 45 67 89" 
                value={phone} 
                onChange={(e) => setPhone(e.target.value)} 
              />
            </div>
            
            <div className="form-group">
              <label className="form-label">Options d'expédition</label>
              <select 
                multiple 
                value={selectedShippingOptions} 
                onChange={(e) => setSelectedShippingOptions(Array.from(e.target.selectedOptions, option => option.value))}
                className="form-input form-select-multiple"
              >
                {shippingOptions.map(option => (
                  <option key={option.id} value={option.id}>
                    {option.name}
                  </option>
                ))}
              </select>
              <span style={{ fontSize: "0.75rem", color: "#6b7280", marginTop: "0.25rem" }}>
                Maintenez Ctrl (ou Cmd) enfoncé pour sélectionner plusieurs options.
              </span>
            </div>
            
            <button 
              type="submit" 
              className="btn-primary"
              disabled={submitting}
            >
              {submitting ? "Création en cours..." : "Créer l'entreprise"}
            </button>
          </form>
        </div>

        {/* Panneau de la liste */}
        <div className="card" style={{ padding: "0", overflow: "hidden" }}>
          <div style={{ padding: "1.5rem", borderBottom: "1px solid #e5e7eb" }}>
            <h2 className="card-title" style={{ margin: "0" }}>Compagnies enregistrées</h2>
          </div>
          
          {loading ? (
            <div style={{ padding: "3rem", textAlign: "center", color: "#6b7280" }}>
              Chargement en cours...
            </div>
          ) : companies.length === 0 ? (
            <div className="empty-state">
              <div className="empty-state-icon">🚚</div>
              <p className="empty-state-text">Aucune entreprise de livraison enregistrée pour le moment.</p>
            </div>
          ) : (
            <div className="table-container">
              <table className="admin-table">
                <thead>
                  <tr>
                    <th>Nom</th>
                    <th>Email</th>
                    <th>Téléphone</th>
                    <th>Statut</th>
                    <th style={{ textAlign: "right" }}>Actions</th>
                  </tr>
                </thead>
                <tbody>
                  {companies.map((company) => (
                    <tr key={company.id}>
                      <td style={{ fontWeight: "500", color: "#111827" }}>{company.name}</td>
                      <td>{company.email}</td>
                      <td>{company.phone || "—"}</td>
                      <td>
                        <span className={`badge ${company.is_active ? "badge-active" : "badge-inactive"}`}>
                          {company.is_active ? "Actif" : "Inactif"}
                        </span>
                      </td>
                      <td style={{ textAlign: "right" }}>
                        <button
                          onClick={() => handleDelete(company.id, company.name)}
                          className="btn-delete"
                          disabled={deletingId === company.id}
                        >
                          {deletingId === company.id ? "Suppression..." : "Supprimer"}
                        </button>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
