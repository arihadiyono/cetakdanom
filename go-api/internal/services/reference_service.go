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
