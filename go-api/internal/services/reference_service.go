package services

import (
	"context"

	"cetakdanom/api/internal/models"
	"cetakdanom/api/internal/repositories"
)

type ReferenceService struct {
	repo *repositories.ReferenceRepository
}

func NewReferenceService(repo *repositories.ReferenceRepository) *ReferenceService {
	return &ReferenceService{repo: repo}
}

func (s *ReferenceService) GetProjects(ctx context.Context, jenis string) ([]models.ProjectRef, error) {
	return s.repo.GetProjects(ctx, jenis)
}

func (s *ReferenceService) GetTahapByProject(ctx context.Context, jenis, projectId string) ([]models.TahapRef, error) {
	return s.repo.GetTahapByProject(ctx, jenis, projectId)
}

func (s *ReferenceService) GetAllKabupaten(ctx context.Context) ([]models.WilayahKabupaten, error) {
	return s.repo.GetAllKabupaten(ctx)
}

func (s *ReferenceService) GetKecamatanByKabupaten(ctx context.Context, kabId string) ([]models.WilayahKecamatan, error) {
	return s.repo.GetKecamatanByKabupaten(ctx, kabId)
}

func (s *ReferenceService) GetDesaByKecamatan(ctx context.Context, kecId, kabId string) ([]models.WilayahDesa, error) {
	return s.repo.GetDesaByKecamatan(ctx, kecId, kabId)
}

// Backward-compatible methods
func (s *ReferenceService) GetLayanan(ctx context.Context) ([]models.LayananBansos, error) {
	return s.repo.GetLayanan(ctx)
}

func (s *ReferenceService) GetTahap(ctx context.Context, projectId string) ([]models.TahapBansos, error) {
	return s.repo.GetTahap(ctx, projectId)
}

func (s *ReferenceService) GetKabupaten(ctx context.Context, nopend, idPetugas, nippos string) ([]models.WilayahKabupaten, error) {
	return s.repo.GetKabupaten(ctx, nopend, idPetugas, nippos)
}

func (s *ReferenceService) GetKecamatan(ctx context.Context, kabId, nopend, idPetugas, nippos string) ([]models.WilayahKecamatan, error) {
	return s.repo.GetKecamatan(ctx, kabId, nopend, idPetugas, nippos)
}

func (s *ReferenceService) GetKelurahan(ctx context.Context, kecId, nopend, idPetugas, nippos string) ([]models.WilayahKelurahan, error) {
	return s.repo.GetKelurahan(ctx, kecId, nopend, idPetugas, nippos)
}
