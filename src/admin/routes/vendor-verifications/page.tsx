import { defineRouteConfig } from "@medusajs/admin-sdk";
import { useEffect, useState } from "react";

export const config = defineRouteConfig({
  label: "Vérifications vendeurs",
});

type ListItem = {
  id: string;
  status: "pending" | "approved" | "rejected";
  legal_name: string;
  registration_number: string | null;
  contact_phone: string;
  submitted_at: string;
  reviewed_at: string | null;
  rejection_reason: string | null;
  document_count: number;
  vendor: { id: string; name?: string; handle?: string; logo?: string; is_verified?: boolean };
};

type Detail = ListItem & {
  id_document_type: string;
  id_document_number: string;
  tax_id: string | null;
  contact_address: string;
  documents: { kind: string; filename: string; url: string | null }[];
  vendor: any;
};

const STATUS_LABEL: Record<string, string> = {
  pending: "En attente",
  approved: "Approuvé",
  rejected: "Refusé",
};

const DOCUMENT_LABEL: Record<string, string> = {
  id_front: "Pièce d'identité — recto",
  id_back: "Pièce d'identité — verso",
  registration: "Document d'immatriculation",
  proof_of_address: "Justificatif de domicile",
};

const ID_TYPE_LABEL: Record<string, string> = {
  national_id: "Carte nationale d'identité",
  passport: "Passeport",
  driver_license: "Permis de conduire",
};

const formatDate = (value?: string | null) =>
  value
    ? new Date(value).toLocaleDateString("fr-FR", {
        day: "numeric",
        month: "long",
        year: "numeric",
        hour: "2-digit",
        minute: "2-digit",
      })
    : "—";

export default function VendorVerificationsPage() {
  const [items, setItems] = useState<ListItem[]>([]);
  const [statusFilter, setStatusFilter] = useState<"pending" | "approved" | "rejected" | "all">("pending");
  const [selectedId, setSelectedId] = useState<string | null>(null);
  const [detail, setDetail] = useState<Detail | null>(null);
  const [loading, setLoading] = useState(true);
  const [detailLoading, setDetailLoading] = useState(false);
  const [acting, setActing] = useState(false);
  const [rejecting, setRejecting] = useState(false);
  const [rejectReason, setRejectReason] = useState("");

  const fetchData = async (method: "GET" | "POST", url: string, body?: any) => {
    try {
      const options: RequestInit = {
        method,
        headers: { "Content-Type": "application/json" },
        credentials: "include",
      };
      if (body) options.body = JSON.stringify(body);

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

  const fetchList = async () => {
    setLoading(true);
    const data = await fetchData("GET", `/admin/vendor-verifications?status=${statusFilter}`);
    if (data) setItems(data.vendor_verifications);
    setLoading(false);
  };

  const fetchDetail = async (id: string) => {
    setDetailLoading(true);
    setRejecting(false);
    setRejectReason("");
    const data = await fetchData("GET", `/admin/vendor-verifications/${id}`);
    setDetail(data ? data.vendor_verification : null);
    setDetailLoading(false);
  };

  useEffect(() => {
    fetchList();
    setSelectedId(null);
    setDetail(null);
  }, [statusFilter]);

  useEffect(() => {
    if (selectedId) fetchDetail(selectedId);
  }, [selectedId]);

  const handleApprove = async () => {
    if (!detail) return;
    if (!confirm(`Approuver le dossier de « ${detail.vendor?.name} » ? La boutique recevra le badge vérifié et ses produits en attente seront mis en ligne.`)) {
      return;
    }
    setActing(true);
    const data = await fetchData("POST", `/admin/vendor-verifications/${detail.id}/approve`);
    setActing(false);
    if (data) {
      await fetchList();
      await fetchDetail(detail.id);
    }
  };

  const handleReject = async () => {
    if (!detail) return;
    if (rejectReason.trim().length < 5) {
      alert("Indiquez un motif d'au moins 5 caractères — il est transmis tel quel au vendeur.");
      return;
    }
    setActing(true);
    const data = await fetchData("POST", `/admin/vendor-verifications/${detail.id}/reject`, {
      rejection_reason: rejectReason.trim(),
    });
    setActing(false);
    if (data) {
      setRejecting(false);
      setRejectReason("");
      await fetchList();
      await fetchDetail(detail.id);
    }
  };

  return (
    <div className="admin-page-container">
      <style>{`
        .admin-page-container {
          padding: 2rem;
          font-family: 'Inter', -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
          color: #1f2937;
          background-color: #f9fafb;
          min-height: 100vh;
        }
        .page-header {
          margin-bottom: 1.5rem;
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
        .filters {
          display: flex;
          gap: 0.5rem;
          margin-bottom: 1.5rem;
          flex-wrap: wrap;
        }
        .filter-btn {
          padding: 0.375rem 0.875rem;
          font-size: 0.8125rem;
          font-weight: 500;
          border-radius: 999px;
          border: 1px solid #d1d5db;
          background-color: #ffffff;
          color: #374151;
          cursor: pointer;
          transition: all 0.15s;
        }
        .filter-btn:hover { border-color: #9ca3af; }
        .filter-btn.active {
          background-color: #4f46e5;
          border-color: #4f46e5;
          color: #ffffff;
        }
        .grid-layout {
          display: grid;
          grid-template-columns: 1fr;
          gap: 1.5rem;
          align-items: start;
        }
        @media(min-width: 1024px) {
          .grid-layout { grid-template-columns: 380px 1fr; }
        }
        .card {
          background-color: #ffffff;
          border-radius: 12px;
          border: 1px solid #e5e7eb;
          box-shadow: 0 1px 3px 0 rgba(0, 0, 0, 0.05), 0 1px 2px 0 rgba(0, 0, 0, 0.03);
          padding: 1.5rem;
        }
        .card-title {
          font-size: 1.125rem;
          font-weight: 600;
          color: #111827;
          margin: 0 0 1rem;
        }
        .list { display: flex; flex-direction: column; gap: 0.5rem; }
        .list-item {
          text-align: left;
          width: 100%;
          padding: 0.875rem 1rem;
          border-radius: 10px;
          border: 1px solid #e5e7eb;
          background-color: #ffffff;
          cursor: pointer;
          transition: all 0.15s;
          box-sizing: border-box;
        }
        .list-item:hover { border-color: #a5b4fc; background-color: #f5f3ff; }
        .list-item.selected { border-color: #4f46e5; background-color: #eef2ff; }
        .list-item-title {
          font-weight: 600;
          font-size: 0.9375rem;
          color: #111827;
          display: block;
        }
        .list-item-meta {
          font-size: 0.75rem;
          color: #6b7280;
          margin-top: 0.25rem;
          display: block;
        }
        .badge {
          display: inline-block;
          padding: 0.125rem 0.5rem;
          border-radius: 999px;
          font-size: 0.6875rem;
          font-weight: 600;
          text-transform: uppercase;
          letter-spacing: 0.03em;
        }
        .badge-pending { background-color: #fef3c7; color: #92400e; }
        .badge-approved { background-color: #d1fae5; color: #065f46; }
        .badge-rejected { background-color: #fee2e2; color: #991b1b; }
        .field-grid {
          display: grid;
          grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
          gap: 1rem 1.5rem;
          margin-bottom: 1.5rem;
        }
        .field-label {
          font-size: 0.75rem;
          color: #6b7280;
          text-transform: uppercase;
          letter-spacing: 0.04em;
          margin: 0 0 0.125rem;
        }
        .field-value {
          font-size: 0.9375rem;
          color: #111827;
          margin: 0;
          word-break: break-word;
        }
        .section-title {
          font-size: 0.875rem;
          font-weight: 600;
          color: #374151;
          margin: 1.5rem 0 0.75rem;
          padding-top: 1.25rem;
          border-top: 1px solid #e5e7eb;
        }
        .doc-list { display: flex; flex-direction: column; gap: 0.5rem; }
        .doc-item {
          display: flex;
          align-items: center;
          justify-content: space-between;
          gap: 1rem;
          padding: 0.75rem 1rem;
          border: 1px solid #e5e7eb;
          border-radius: 8px;
          background-color: #f9fafb;
        }
        .doc-name { font-size: 0.875rem; color: #111827; }
        .doc-file { font-size: 0.75rem; color: #6b7280; }
        .doc-link {
          font-size: 0.8125rem;
          font-weight: 600;
          color: #4f46e5;
          text-decoration: none;
          white-space: nowrap;
        }
        .doc-link:hover { text-decoration: underline; }
        .doc-missing { font-size: 0.8125rem; color: #9ca3af; white-space: nowrap; }
        .actions { display: flex; gap: 0.75rem; margin-top: 1.5rem; flex-wrap: wrap; }
        .btn {
          font-weight: 600;
          font-size: 0.875rem;
          padding: 0.625rem 1.25rem;
          border-radius: 8px;
          border: 1px solid transparent;
          cursor: pointer;
          transition: background-color 0.15s, transform 0.1s;
        }
        .btn:disabled { opacity: 0.55; cursor: not-allowed; }
        .btn-approve { background-color: #059669; color: #ffffff; }
        .btn-approve:hover:not(:disabled) { background-color: #047857; }
        .btn-reject { background-color: #ffffff; color: #b91c1c; border-color: #fca5a5; }
        .btn-reject:hover:not(:disabled) { background-color: #fef2f2; }
        .btn-cancel { background-color: #ffffff; color: #374151; border-color: #d1d5db; }
        .reject-box {
          margin-top: 1.25rem;
          padding: 1rem;
          border: 1px solid #fca5a5;
          border-radius: 10px;
          background-color: #fef2f2;
        }
        .form-textarea {
          width: 100%;
          box-sizing: border-box;
          padding: 0.625rem 0.875rem;
          font-size: 0.875rem;
          font-family: inherit;
          border: 1px solid #d1d5db;
          border-radius: 8px;
          min-height: 90px;
          resize: vertical;
        }
        .form-textarea:focus {
          outline: 2px solid transparent;
          border-color: #dc2626;
          box-shadow: 0 0 0 3px rgba(220, 38, 38, 0.1);
        }
        .hint { font-size: 0.75rem; color: #6b7280; margin: 0.5rem 0 0; }
        .empty {
          text-align: center;
          padding: 3rem 1rem;
          color: #9ca3af;
          font-size: 0.875rem;
        }
        .callout {
          padding: 0.875rem 1rem;
          border-radius: 8px;
          font-size: 0.875rem;
          margin-bottom: 1.25rem;
        }
        .callout-rejected { background-color: #fef2f2; color: #991b1b; border: 1px solid #fecaca; }
        .callout-approved { background-color: #ecfdf5; color: #065f46; border: 1px solid #a7f3d0; }
      `}</style>

      <div className="page-header">
        <h1 className="page-title">Vérifications vendeurs</h1>
        <p className="page-subtitle">
          Contrôlez l'identité des boutiques avant de leur accorder le badge « Vérifié ».
          Tant qu'une boutique n'est pas approuvée, ses produits restent en brouillon et
          n'apparaissent pas en vitrine.
        </p>
      </div>

      <div className="filters">
        {(["pending", "approved", "rejected", "all"] as const).map((s) => (
          <button
            key={s}
            className={`filter-btn ${statusFilter === s ? "active" : ""}`}
            onClick={() => setStatusFilter(s)}
          >
            {s === "all" ? "Tous" : STATUS_LABEL[s]}
          </button>
        ))}
      </div>

      <div className="grid-layout">
        <div className="card">
          <h2 className="card-title">
            Dossiers {loading ? "" : `(${items.length})`}
          </h2>
          {loading ? (
            <p className="empty">Chargement…</p>
          ) : items.length === 0 ? (
            <p className="empty">Aucun dossier dans cette catégorie.</p>
          ) : (
            <div className="list">
              {items.map((item) => (
                <button
                  key={item.id}
                  className={`list-item ${selectedId === item.id ? "selected" : ""}`}
                  onClick={() => setSelectedId(item.id)}
                >
                  <span className="list-item-title">{item.vendor?.name || item.legal_name}</span>
                  <span className="list-item-meta">
                    <span className={`badge badge-${item.status}`}>{STATUS_LABEL[item.status]}</span>
                    {" · "}
                    {item.document_count} pièce{item.document_count > 1 ? "s" : ""}
                    {" · "}
                    {formatDate(item.submitted_at)}
                  </span>
                </button>
              ))}
            </div>
          )}
        </div>

        <div className="card">
          {!selectedId ? (
            <p className="empty">Sélectionnez un dossier pour l'examiner.</p>
          ) : detailLoading || !detail ? (
            <p className="empty">Chargement du dossier…</p>
          ) : (
            <>
              <h2 className="card-title">
                {detail.vendor?.name}{" "}
                <span className={`badge badge-${detail.status}`}>{STATUS_LABEL[detail.status]}</span>
              </h2>

              {detail.status === "rejected" && (
                <div className="callout callout-rejected">
                  <strong>Refusé le {formatDate(detail.reviewed_at)}</strong>
                  <br />
                  {detail.rejection_reason}
                </div>
              )}
              {detail.status === "approved" && (
                <div className="callout callout-approved">
                  Approuvé le {formatDate(detail.reviewed_at)}. La boutique porte le badge « Vérifié ».
                </div>
              )}

              <div className="field-grid">
                <div>
                  <p className="field-label">Responsable légal</p>
                  <p className="field-value">{detail.legal_name}</p>
                </div>
                <div>
                  <p className="field-label">Pièce d'identité</p>
                  <p className="field-value">
                    {ID_TYPE_LABEL[detail.id_document_type] || detail.id_document_type}
                    <br />
                    <span className="doc-file">n° {detail.id_document_number}</span>
                  </p>
                </div>
                <div>
                  <p className="field-label">Téléphone</p>
                  <p className="field-value">{detail.contact_phone}</p>
                </div>
                <div>
                  <p className="field-label">Adresse</p>
                  <p className="field-value">{detail.contact_address}</p>
                </div>
                <div>
                  <p className="field-label">Immatriculation</p>
                  <p className="field-value">{detail.registration_number || "—"}</p>
                </div>
                <div>
                  <p className="field-label">Identifiant fiscal</p>
                  <p className="field-value">{detail.tax_id || "—"}</p>
                </div>
                <div>
                  <p className="field-label">Soumis le</p>
                  <p className="field-value">{formatDate(detail.submitted_at)}</p>
                </div>
                <div>
                  <p className="field-label">Comptes de la boutique</p>
                  <p className="field-value">
                    {(detail.vendor?.admins || []).map((a: any) => a.email).join(", ") || "—"}
                  </p>
                </div>
              </div>

              <h3 className="section-title">Pièces jointes</h3>
              <div className="doc-list">
                {detail.documents.length === 0 ? (
                  <p className="empty">Aucune pièce jointe.</p>
                ) : (
                  detail.documents.map((doc, i) => (
                    <div className="doc-item" key={`${doc.kind}-${i}`}>
                      <div>
                        <div className="doc-name">{DOCUMENT_LABEL[doc.kind] || doc.kind}</div>
                        <div className="doc-file">{doc.filename}</div>
                      </div>
                      {doc.url ? (
                        <a className="doc-link" href={doc.url} target="_blank" rel="noopener noreferrer">
                          Ouvrir
                        </a>
                      ) : (
                        <span className="doc-missing">Fichier indisponible</span>
                      )}
                    </div>
                  ))
                )}
              </div>
              <p className="hint">
                Les liens sont signés et expirent au bout de quelques minutes. Rechargez le dossier
                si un lien ne s'ouvre plus.
              </p>

              {detail.status === "pending" && (
                <>
                  <div className="actions">
                    <button className="btn btn-approve" onClick={handleApprove} disabled={acting}>
                      {acting ? "Traitement…" : "Approuver la boutique"}
                    </button>
                    {!rejecting && (
                      <button className="btn btn-reject" onClick={() => setRejecting(true)} disabled={acting}>
                        Refuser
                      </button>
                    )}
                  </div>

                  {rejecting && (
                    <div className="reject-box">
                      <p className="field-label" style={{ marginBottom: "0.5rem" }}>
                        Motif du refus
                      </p>
                      <textarea
                        className="form-textarea"
                        value={rejectReason}
                        onChange={(e) => setRejectReason(e.target.value)}
                        placeholder="Ex. : la photo de la pièce d'identité est illisible, merci de la renvoyer en meilleure qualité."
                      />
                      <p className="hint">
                        Ce texte est envoyé tel quel au vendeur. Soyez précis : il doit savoir quoi
                        corriger pour re-soumettre.
                      </p>
                      <div className="actions">
                        <button className="btn btn-reject" onClick={handleReject} disabled={acting}>
                          {acting ? "Traitement…" : "Confirmer le refus"}
                        </button>
                        <button
                          className="btn btn-cancel"
                          onClick={() => {
                            setRejecting(false);
                            setRejectReason("");
                          }}
                          disabled={acting}
                        >
                          Annuler
                        </button>
                      </div>
                    </div>
                  )}
                </>
              )}
            </>
          )}
        </div>
      </div>
    </div>
  );
}
